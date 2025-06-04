#include "types.h"
#include "stat.h"
#include "user.h"
#include "thread.h" // Your thread library header
#include "fs.h"     // For T_DIR, etc if needed by other includes, not directly by test

#define NUM_THREADS 2
#define NUM_INCREMENTS 100000

volatile int shared_counter = 0;
ticket_lock_t counter_lock;

void incrementer_thread(void *arg1, void *arg2) { // Match clone's function signature
    int thread_num = *(int*)arg1;
    // arg2 is unused in this example, could be passed as 0 or another value
    printf(1, "Thread %d (PID %d): Starting...\n", thread_num, getpid());
    
    for (int i = 0; i < NUM_INCREMENTS; i++) {
        ticket_lock_acquire(&counter_lock);
        shared_counter++;
        ticket_lock_release(&counter_lock);
    }
    
    printf(1, "Thread %d (PID %d): Finished (%d increments).\n", thread_num, getpid(), NUM_INCREMENTS);
    exit(); // IMPORTANT: Threads must call exit()
}

int main(int argc, char *argv[]) {
    int tids[NUM_THREADS]; // To store PIDs returned by thread_create
    int args[NUM_THREADS];
    
    printf(1, "Main (PID %d): Starting test with %d threads, %d increments each...\n",
           getpid(), NUM_THREADS, NUM_INCREMENTS);
    
    ticket_lock_init(&counter_lock);
    
    for (int i = 0; i < NUM_THREADS; i++) {
        args[i] = i + 1; // Thread number 1 to N
        // Pass thread's own arg struct, and a null for arg2
        int ret = thread_create(&tids[i], incrementer_thread, &args[i], 0); 
        if (ret < 0) {
            printf(1, "Main: Failed to create thread %d\n", i + 1);
            continue;
        }
        printf(1, "Main: Created thread %d with PID %d\n", args[i], tids[i]);
    }
    
    printf(1, "Main: Waiting for threads to join...\n");
    for (int i = 0; i < NUM_THREADS; i++) {
        if (tids[i] == 0) continue; // If creation failed for this slot

        int joined_pid = thread_join(); // Joins ANY child thread
        if (joined_pid < 0) {
            printf(1, "Main: Error or no more threads to join.\n");
            break; 
        }
        // To make sure we joined the correct number of threads,
        // we don't really care *which* specific one joined here, just that one did.
        printf(1, "Main: Joined a thread with PID %d.\n", joined_pid);
    }
    
    printf(1, "Main: All threads believed to be joined.\n");
    
    int expected_value = NUM_THREADS * NUM_INCREMENTS;
    printf(1, "Main: Final counter value: %d\n", shared_counter);
    printf(1, "Main: Expected counter value: %d\n", expected_value);

    if (shared_counter == expected_value) {
        printf(1, "SUCCESS: Counter matches expected value!\n");
    } else {
        printf(1, "FAILURE: Counter mismatch!\n");
    }
   
    exit();
}