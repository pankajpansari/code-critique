#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
int
sys_clone(void)
{
  void (*fcn)(void *, void *);
  void *arg1, *arg2, *stack;
  struct proc *curproc = myproc();

  if (argptr(0, (char **)&fcn, sizeof(void (*)(void *, void *))) < 0 ||
      argptr(1, (char **)&arg1, sizeof(void *)) < 0 ||
      argptr(2, (char **)&arg2, sizeof(void *)) < 0 ||
      argptr(3, (char **)&stack, sizeof(void *)) < 0) {
    return -1;
  }

  // Check if stack is page-aligned (optional, but good practice as per spec)
  // PGSIZE is defined in memlayout.h
  // if ((uint)stack % PGSIZE != 0) {
  //     cprintf("clone: stack not page aligned\n");
  //     return -1;
  // }
// Check if stack is within user address space (important!) - KEEP THIS CHECK
if ((uint)stack >= curproc->sz || (uint)stack + PGSIZE > curproc->sz || (uint)stack + PGSIZE < (uint)stack /*overflow*/) {
    // Or if stack is in kernel space: (uint)stack >= KERNBASE
    cprintf("clone: stack invalid (outside user space or wraps around)\n"); // Modified message for clarity
    return -1;
}


  return clone(fcn, arg1, arg2, stack);
}
int
sys_join(void)
{
  void **stack_ptr_user; // This is a pointer to where the user wants the stack address stored

  if (argptr(0, (char **)&stack_ptr_user, sizeof(void **)) < 0) {
    return -1;
  }
  return join(stack_ptr_user);
}
