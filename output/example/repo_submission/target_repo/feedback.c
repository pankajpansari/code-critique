
/*============================threadtest.c=========================================/*

/* 
 * REVIEW: The include of "fs.h" is not used in this program. Removing unnecessary headers 
 * can reduce compilation time and improve clarity.
 */
line 5: | + #include "fs.h"     // For T_DIR, etc if needed by other includes, not directly by test

/* 
 * REVIEW: Indentation here is 5 spaces, but the project style recommends 2–4 spaces per 
 * level. Please adjust to match the agreed indentation width.
 */
line 18:  | +     for (int i = 0; i < NUM_INCREMENTS; i++) {

/* 
 * REVIEW: The array `tids` is declared but not initialized. If `thread_create` fails, 
 * `tids[i]` remains indeterminate. Consider initializing the array (e.g., to 0) or 
 * setting `tids[i] = 0` when creation fails.
 */
line 29:  | +     int tids[NUM_THREADS]; // To store PIDs returned by thread_create

/* 
 * REVIEW: You check `if (tids[i] == 0)` to skip failed threads, but since `tids[i]` may be 
 * uninitialized, this check is unreliable. Instead, track success via the return 
 * value of `thread_create` or ensure `tids[i]` is always set on both success and 
 * failure.
 */
line 50:  | +         if (tids[i] == 0) continue; // If creation failed for this slot

/*============================proc.c=========================================/*

/* 
 * REVIEW: The closing brace here appears on its own and may misalign with the opening 
 * `mycpu()` definition. Ensure the brace is indented consistently and the function 
 * structure is clear.
 */
line 53:  | + }

/* 
 * REVIEW: The prototype for `wakeup1()` is declared twice (also at line 21). Remove the 
 * redundant declaration to avoid confusion.
 */
line 57:  | + void wakeup1(void *chan);

/* 
 * REVIEW: Consider adding a function comment header for `clone()` summarizing its purpose, 
 * parameters, and return values to improve readability and maintenance.
 */
line 72:  | + clone(void (*fcn)(void *, void *), void *arg1, void *arg2, void *stack)

/* 
 * REVIEW: This `cprintf` debug statement (and similar ones on lines 84, 109, 121, 131, 
 * 163) should be removed or guarded by a debug flag before final submission to 
 * avoid cluttering kernel output.
 */
line 79:  | +   cprintf("kernel clone: called with stack=0x%x, fcn=0x%x\n", stack, fcn);

/* 
 * REVIEW: Hard-coding `4` when adjusting the stack pointer reduces portability. Use 
 * `sizeof(uint)` or `sizeof(void*)` for clarity and correctness on different 
 * architectures.
 */
line 106: 6 | +   ustack_ptr -= 4;

/* 
 * REVIEW: Large block of commented-out `join()` implementation is dead code in this 
 * context. Remove it or move it to a separate patch to keep the file concise.
 */
line 167: 7 | + // In kernel/proc.c

/* 
 * REVIEW: Returning `-2` for a `copyout` failure diverges from the `-1` convention used 
 * elsewhere. Consider unifying error codes or documenting this special case so 
 * callers can handle it properly.
 */
line 460: 0 | +         if (copyout(curproc->pgdir, (uint)stack_ptr_user, &p->user_stack, sizeof(void *)) < 0) {

/* 
 * REVIEW: `check_and_free_shared_pgdir()` nicely encapsulates shared-pgdir logic. Add a 
 * brief comment stating its precondition (e.g., 'assumes ptable.lock is held') to 
 * guide future maintainers.
 */
line 501: 1 | + check_and_free_shared_pgdir(struct proc *dying_proc)

/*============================syscall.c=========================================/*

/* 
 * REVIEW: Indentation of the `static int (*syscalls[])` declaration and its entries should 
 * match the existing style in this file (e.g., two spaces from the margin). 
 * Consistent indentation improves readability and helps maintain a uniform 
 * codebase.
 */
line 109: 9 | + static int (*syscalls[])(void) = {

/* 
 * REVIEW: Designated initializers in C require an `=` after the index. Change `[SYS_fork] 
 * sys_fork,` to `[SYS_fork] = sys_fork,` (and similarly for all entries) to 
 * conform to standard C syntax and avoid compiler errors.
 */
line 110: 0 | + [SYS_fork]    sys_fork,

/* 
 * REVIEW: Add a brief function‐header comment above `syscall()` summarizing its role 
 * (dispatching system calls based on %eax). A per‐function overview aids future 
 * maintainers in quickly understanding its purpose.
 */
line 135: 5 | + void

/*============================sysproc.c=========================================/*

/* 
 * REVIEW: Add a brief header comment for sys_clone explaining its purpose, expected 
 * arguments, and return value. This matches the style of other syscall definitions 
 * and aids future maintenance.
 */
line 93:  | + sys_clone(void)

/* 
 * REVIEW: The name `fcn` is terse and non-descriptive. Consider renaming to something like 
 * `start_routine` or `fn` to more clearly convey its role.
 */
line 95:  | +   void (*fcn)(void *, void *);

/* 
 * REVIEW: The alignment check is commented out. Either fully enable this runtime check 
 * (per the assignment spec) or remove the dead code to keep the implementation 
 * uncluttered.
 */
line 108: 8 | +   // if ((uint)stack % PGSIZE != 0) {

/* 
 * REVIEW: This compound `if` condition is quite long and dense. Break it into multiple 
 * sub-checks or extract parts into well-named boolean variables (e.g., 
 * `stack_overflows` and `stack_outside_user_space`) for clarity.
 */
line 113: 3 | + if ((uint)stack >= curproc->sz || (uint)stack + PGSIZE > curproc->sz || (uint)stack + PGSIZE < (uint)stack /*overflow*/) {

/* 
 * REVIEW: Using `cprintf` in a syscall for argument validation can flood the kernel log on 
 * bad user calls. It’s cleaner to silently return `-1` and let the user-level 
 * library handle diagnostics.
 */
line 115: 5 | +     cprintf("clone: stack invalid (outside user space or wraps around)\n"); // Modified message for clarity

/* 
 * REVIEW: Add a function comment for sys_join describing its behavior (waiting on a 
 * thread, where the stack pointer is stored, and the return semantics). This keeps 
 * the syscall interface self-documented.
 */
line 123: 3 | + sys_join(void)

/* 
 * REVIEW: You cast to `(char **)` when fetching a `void **` from user space. Consider 
 * casting to `(void ***)` or using an intermediate `char *` to avoid potential 
 * pointer-type mismatches and compiler warnings.
 */
line 127: 7 | +   if (argptr(0, (char **)&stack_ptr_user, sizeof(void **)) < 0) {

/*============================ulib.c=========================================/*

/* 
 * REVIEW: You reimplement `strcpy` here, which may conflict with existing library versions 
 * and increases maintenance burden. If XV6’s user library already provides this, 
 * prefer that. Otherwise, mark it `static` to limit its scope or document why a 
 * custom version is needed.
 */
line 14:  | + strcpy(char *s, const char *t)

/* 
 * REVIEW: This custom `memset` duplicates standard functionality. If a user‐level `memset` 
 * exists in XV6, use it. Otherwise, declare this function `static` and add a brief 
 * comment explaining why a custom version is required.
 */
line 42:  | + memset(void *dst, int c, uint n)

/* 
 * REVIEW: Your `memmove` always copies forward and does not handle overlapping 
 * source/destination regions correctly. Either rename it to `memcpy` (and document 
 * no-overlap requirement) or add logic to detect overlap and copy backwards when 
 * necessary.
 */
line 114: 4 | +     *dst++ = *src++;

/* 
 * REVIEW: The spec defines `thread_create` as returning the thread ID directly (and 
 * returning 0 in the child). Here you take an extra `int *tid` out parameter. 
 * Consider matching the assignment’s prototype or clearly document the difference.
 */
line 121: 1 | + thread_create(int *tid, void (*start_routine)(void *, void *), void *arg1, void *arg2)

/* 
 * REVIEW: `malloc` does not guarantee page alignment on XV6. Since `clone` requires a 
 * page-aligned stack, ensure the pointer you pass is page-aligned (e.g. allocate 
 * extra bytes and round up, or use a page-size allocator).
 */
line 125: 5 | +   stack = malloc(USER_THREAD_STACK_SIZE);

/* 
 * REVIEW: You pass the base of the allocated stack to `clone`, but on x86 the stack grows 
 * downward: you should pass `stack + USER_THREAD_STACK_SIZE` (the top of the 
 * stack) to the syscall so the thread starts with a valid stack pointer.
 */
line 131: 1 | +   int pid = clone(start_routine, arg1, arg2, stack);

/* 
 * REVIEW: Your lock APIs (`ticket_lock_t`, `ticket_lock_init`, `ticket_lock_acquire`, 
 * `ticket_lock_release`) differ in naming from the spec’s `lock_t`, `lock_init`, 
 * `lock_acquire`, `lock_release`. Align names with the assignment or update your 
 * `thread.h` accordingly to avoid confusion.
 */
line 165: 5 | + ticket_lock_init(ticket_lock_t *lk)
