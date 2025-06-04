#include "types.h"
#include "stat.h"
#include "fcntl.h"
#include "user.h"   // For syscall wrappers (open, close, read, clone, join, etc.), printf
#include "thread.h" // Your thread library header (for ticket_lock_t, xadd)
// x86.h is not strictly needed here if stosb is handled by compiler/linker for user space,
// or if you use a C version of memset. Let's assume it's fine for now.
// #include "x86.h"

// Define a reasonable stack size for user threads.
#define USER_THREAD_STACK_SIZE 4096

char*
strcpy(char *s, const char *t)
{
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    ;
  return os;
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    p++, q++;
  return (uchar)*p - (uchar)*q;
}

uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
    ;
  return n;
}
void*
memset(void *dst, int c, uint n)
{
  char *cdst = (char *)dst; // Cast to char* for byte-wise assignment
  uint i;
  for(i = 0; i < n; i++){
    cdst[i] = (char)c; // Ensure c is treated as a byte
  }
  return dst;
}


char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
}

char*
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
  return buf;
}

int
stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
  close(fd);
  return r;
}

int
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
{
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
  return vdst;
}

// --- Thread library functions added below ---

int
thread_create(int *tid, void (*start_routine)(void *, void *), void *arg1, void *arg2)
{
  void *stack;

  stack = malloc(USER_THREAD_STACK_SIZE);
  if (stack == 0) {
    printf(1, "thread_create: unable to allocate stack using malloc.\n");
    return -1;
  }

  int pid = clone(start_routine, arg1, arg2, stack);

  if (pid < 0) {
    printf(1, "thread_create: clone failed\n");
    free(stack);
    return -1;
  }

  if (pid > 0) { 
    if (tid) {
      *tid = pid;
    }
  }
  return pid;
}


int
thread_join(void)
{
  void *child_stack;
  int pid;

  pid = join(&child_stack);

  if (pid > 0 && child_stack != 0) {
    free(child_stack);
  } else if (pid > 0 && child_stack == 0) {
    printf(1, "thread_join: Null Stack! on joining thread PID %d\n", pid);
  }
  return pid;
}

void
ticket_lock_init(ticket_lock_t *lk)
{
  lk->ticket = 0;
  lk->turn = 0;
}

void
ticket_lock_acquire(ticket_lock_t *lk)
{
  uint my_ticket = xadd(&lk->ticket, 1);
  while (lk->turn != my_ticket) {
    asm volatile("pause");
  }
}

void
ticket_lock_release(ticket_lock_t *lk)
{
  xadd(&lk->turn, 1);
}

