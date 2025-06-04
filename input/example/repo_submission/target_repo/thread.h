#ifndef _THREAD_H_
#define _THREAD_H_

#include "types.h" 

typedef struct __ticket_lock_t {
  uint ticket;
  uint turn;
} ticket_lock_t;


int thread_create(int *tid, void (*start_routine)(void *, void *), void *arg1, void *arg2);
int thread_join(void); 

// Lock functions
void ticket_lock_init(ticket_lock_t *lk);
void ticket_lock_acquire(ticket_lock_t *lk);
void ticket_lock_release(ticket_lock_t *lk);

// Atomic add using x86 xaddl instruction
static inline uint
xadd(volatile uint *addr, uint val)
{
  asm volatile("lock; xaddl %0, %1"
               : "+r" (val), "+m" (*addr) // val in/out, *addr in/out
               : // no pure inputs
               : "memory");
  return val; // xaddl returns the original value of *addr
}

#endif