#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}


static struct proc* allocproc(void);
void wakeup1(void *chan);

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}
int
clone(void (*fcn)(void *, void *), void *arg1, void *arg2, void *stack)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // --- Add this debug line ---
  cprintf("kernel clone: called with stack=0x%x, fcn=0x%x\n", stack, fcn);
  // --- End of debug line ---

  // Allocate process.
  if((np = allocproc()) == 0){
    cprintf("kernel clone: allocproc failed\n"); // Debug
    return -1;
  }

  // Share address space:
  // Parent and child pgdir point to the same page table.
  // No need for copyuvm.
  np->pgdir = curproc->pgdir;
  np->sz = curproc->sz; // Size of address space is the same

  np->parent = curproc;
  *np->tf = *curproc->tf; // Copy trap frame (registers, etc.)

  // Set up the new thread's user stack:
  // Arguments are pushed in reverse order (arg2, then arg1 for fcn(arg1, arg2))
  // Then a fake return address.
  // PGSIZE is from kernel/memlayout.h
  uint ustack_ptr = (uint)stack + PGSIZE; // Start at the top of the page

  uint fake_ret_pc_val = 0xffffffff; // Variable to hold the value for copyout

  // Fake return PC (0xffffffff as suggested)
  ustack_ptr -= 4;
  // Corrected copyout: pass address of a kernel variable
  if(copyout(np->pgdir, ustack_ptr, &fake_ret_pc_val, sizeof(uint)) < 0) {
      cprintf("kernel clone: copyout fake_ret_pc failed\n"); // Debug
      kfree(np->kstack);
      np->kstack = 0;
      np->state = UNUSED;
      np->is_thread = 0; np->user_stack = 0; // Reset fields
      return -1;
  }

  // Push arg2
  ustack_ptr -= 4;
  if(copyout(np->pgdir, ustack_ptr, &arg2, sizeof(void *)) < 0) {
      cprintf("kernel clone: copyout arg2 failed\n"); // Debug
      kfree(np->kstack);
      np->kstack = 0;
      np->state = UNUSED;
      np->is_thread = 0; np->user_stack = 0; // Reset fields
      return -1;
  }
  
  // Push arg1
  ustack_ptr -= 4;
  if(copyout(np->pgdir, ustack_ptr, &arg1, sizeof(void *)) < 0) {
      cprintf("kernel clone: copyout arg1 failed\n"); // Debug
      kfree(np->kstack);
      np->kstack = 0;
      np->state = UNUSED;
      np->is_thread = 0; np->user_stack = 0; // Reset fields
      return -1;
  }

  np->tf->esp = ustack_ptr; // Set the new thread's stack pointer
  np->tf->eip = (uint)fcn;  // Set the instruction pointer to the function

  // Set return value for child thread to 0
  np->tf->eax = 0;

  // Mark as a thread and store its user stack base (for join)
  np->is_thread = 1;
  np->user_stack = stack; // Store the original stack pointer passed to clone

  // Copy open files.
  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name)); // Can give a more specific name if desired

  pid = np->pid;

  acquire(&ptable.lock);
  np->state = RUNNABLE;
  release(&ptable.lock);

  cprintf("kernel clone: success for pid %d, child of %d\n", pid, curproc->pid); // Debug
  return pid; // Return PID to parent
}

// In kernel/proc.c
// Wait for a child thread to exit and return its PID and stack.
// The user-provided stack_ptr_user is where the child's user_stack will be copied.
// int
// join(void **stack_ptr_user)
// {
//   struct proc *p;
//   int havekids, pid;
//   struct proc *curproc = myproc();

//   acquire(&ptable.lock);
//   for(;;){ // Loop forever until a condition is met
//     // Scan through table looking for exited children (threads).
//     havekids = 0;
//     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
//       if(p->parent != curproc || !p->is_thread) // Not my child or not a thread
//         continue;
      
//       havekids = 1;
//       if(p->state == ZOMBIE){
//         // Found an exited child thread.
//         pid = p->pid;

//         // Copy out the child's user stack pointer.
//         // p->user_stack was set by clone.
//         if (copyout(curproc->pgdir, (uint)stack_ptr_user, &p->user_stack, sizeof(void *)) < 0) {
//             // Failed to copy out stack pointer, this is problematic.
//             // Release lock and return error. Or, perhaps proceed without freeing stack?
//             // For now, let's consider it an error that prevents full cleanup.
//             release(&ptable.lock);
//             return -2; // Indicate a copyout error
//         }

//         kfree(p->kstack);
//         p->kstack = 0;
//         // pgdir is shared, DO NOT free it here like in wait() for a full process.
//         // The address space is freed only when the last process/thread using it exits.
//         // This logic will be in exit() and wait().
//         p->pid = 0;
//         p->parent = 0;
//         p->name[0] = 0;
//         p->killed = 0;
//         p->state = UNUSED;
//         p->is_thread = 0; // Reset flag
//         p->user_stack = 0; // Reset
        
//         release(&ptable.lock);
//         return pid;
//       }
//     }

//     // No exited child threads found.
//     if(!havekids || curproc->killed){
//       release(&ptable.lock);
//       return -1; // No children to wait for, or process was killed.
//     }

//     // Wait for a child thread to exit.
//     sleep(curproc, &ptable.lock);  //DOC: wait-sleep
//   }
// }
//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  p->is_thread = 0; // Default to not a thread; fork() will keep this, clone() will set it
  p->user_stack = 0;

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.

// In kernel/proc.c
// Wait for a child thread to exit and return its PID and stack.
// The user-provided stack_ptr_user is where the child's user_stack will be copied.
int
join(void **stack_ptr_user)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();

  acquire(&ptable.lock);
  for(;;){ // Loop forever until a condition is met
    // Scan through table looking for exited children (threads).
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc || !p->is_thread) // Not my child or not a thread
        continue;
      
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found an exited child thread.
        pid = p->pid;

        // Copy out the child's user stack pointer.
        // p->user_stack was set by clone.
        if (copyout(curproc->pgdir, (uint)stack_ptr_user, &p->user_stack, sizeof(void *)) < 0) {
            // Failed to copy out stack pointer, this is problematic.
            // Release lock and return error. Or, perhaps proceed without freeing stack?
            // For now, let's consider it an error that prevents full cleanup.
            release(&ptable.lock);
            return -2; // Indicate a copyout error
        }

        kfree(p->kstack);
        p->kstack = 0;
        // pgdir is shared, DO NOT free it here like in wait() for a full process.
        // The address space is freed only when the last process/thread using it exits.
        // This logic will be in exit() and wait().
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        p->is_thread = 0; // Reset flag
        p->user_stack = 0; // Reset
        
        release(&ptable.lock);
        return pid;
      }
    }

    // No exited child threads found.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1; // No children to wait for, or process was killed.
    }

    // Wait for a child thread to exit.
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}

// In kernel/proc.c
// Call this *before* clearing p->pgdir, when p is ZOMBIE and being reaped.
// Assumes ptable.lock is held.
void
check_and_free_shared_pgdir(struct proc *dying_proc)
{
  struct proc *p_iter;
  int shared_pgdir_users = 0;

  if (dying_proc->pgdir == 0) // Already freed or never had one
      return;

  // Count how many other active (not UNUSED, not ZOMBIE, not self) processes/threads use this pgdir
  for (p_iter = ptable.proc; p_iter < &ptable.proc[NPROC]; p_iter++) {
    if (p_iter != dying_proc &&                        // Not the dying process itself
        p_iter->pgdir == dying_proc->pgdir &&         // Shares the same page directory
        p_iter->state != UNUSED && p_iter->state != ZOMBIE) { // Is an active user
      shared_pgdir_users++;
    }
  }

  if (shared_pgdir_users == 0) {
    // No other active users of this page directory, safe to free.
    freevm(dying_proc->pgdir);
  }
  // The caller (wait or exit) will set dying_proc->pgdir = 0 after this.
}

int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();

  acquire(&ptable.lock);
  for(;;){
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      // MODIFIED: Only consider non-thread children
      if(p->parent != curproc || p->is_thread) 
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;

        // Address space freeing logic (see below)
        check_and_free_shared_pgdir(p); 

        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        // p->is_thread should already be 0 for processes handled by wait()
        release(&ptable.lock);
        return pid;
      }
    }

    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }
    sleep(curproc, &ptable.lock);
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
