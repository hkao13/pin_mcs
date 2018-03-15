#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>

#define MAXVAL 8
#define NUMTHREADS 2

int temp;
pthread_mutex_t lock;

int semaphore = 1;

struct wonk{
  int a[MAXVAL];
};

struct wonk wonk_array[NUMTHREADS];

int INSTRUMENT_ON() {
  // Need to set some var to keep from optimzing the function call away from -O1
  temp = 1;
  return 0;  
}

int INSTRUMENT_OFF() {
  // Need to set some var to keep from optimzing the function call away from -O1
  temp = 0;
  return 0;  
}

void *accessorThreadRead1(void *arg){

  

  struct wonk *thread_data;
  thread_data = (struct wonk *) arg;
  int* array;
  array = thread_data -> a;
  int i;
  
  // READ
  pthread_mutex_lock(&lock);
  INSTRUMENT_ON();
  i = array[0];
  INSTRUMENT_OFF();
  pthread_mutex_unlock(&lock);

  while (semaphore) {
  }

  // READ
  pthread_mutex_lock(&lock);
  INSTRUMENT_ON();
  i = array[1];
  INSTRUMENT_OFF();
  pthread_mutex_unlock(&lock);

  // READ
  pthread_mutex_lock(&lock);
  INSTRUMENT_ON();
  i = array[1];
  INSTRUMENT_OFF();
  pthread_mutex_unlock(&lock);

  pthread_exit(NULL); 
}


void *accessorThreadRead2(void *arg){

  

  struct wonk *thread_data;
  thread_data = (struct wonk *) arg;
  int* array;
  array = thread_data -> a;
  int i;
  
  // READ
  pthread_mutex_lock(&lock);
  INSTRUMENT_ON();
  i = array[0];
  INSTRUMENT_OFF();
  pthread_mutex_unlock(&lock);

  while (semaphore) {
  }

  // READ
  pthread_mutex_lock(&lock);
  INSTRUMENT_ON();
  i = array[0];
  INSTRUMENT_OFF();
  pthread_mutex_unlock(&lock);

  // READ
  pthread_mutex_lock(&lock);
  INSTRUMENT_ON();
  i = array[0];
  INSTRUMENT_OFF();
  pthread_mutex_unlock(&lock);

  pthread_exit(NULL); 
}

void *accessorThreadWrite(void *arg){

  

  struct wonk *thread_data;
  thread_data = (struct wonk *) arg;
  int* array;
  array = thread_data -> a;
  int i;

  // READ
  pthread_mutex_lock(&lock);
  INSTRUMENT_ON();
  i = array[0];
  INSTRUMENT_OFF();
  pthread_mutex_unlock(&lock);

  usleep(100 + (rand() % 100) );

  // WRITE
  pthread_mutex_lock(&lock);
  INSTRUMENT_ON();
  array[0] = 0xffff;
  INSTRUMENT_OFF();
  pthread_mutex_unlock(&lock);

  semaphore = 0;

  // READ
  pthread_mutex_lock(&lock);
  INSTRUMENT_ON();
  i = array[0];
  INSTRUMENT_OFF();
  pthread_mutex_unlock(&lock);

  pthread_exit(NULL); 
}

int main(int argc, char *argv[]){

  INSTRUMENT_OFF();

  pthread_t acc[NUMTHREADS];

  pthread_mutex_init(&lock,NULL);

  wonk_array[0].a[0] = 0xabab;

  pthread_create(&acc[0],NULL,accessorThreadWrite,(void *)&wonk_array[0]);
  pthread_create(&acc[1],NULL,accessorThreadRead1,(void *)&wonk_array[0]);
  pthread_create(&acc[2],NULL,accessorThreadRead2,(void *)&wonk_array[0]);
  pthread_join(acc[0],NULL);
  pthread_join(acc[1],NULL);
  pthread_join(acc[2],NULL);

  pthread_mutex_destroy(&lock);

  INSTRUMENT_OFF();

  

  return 0;

}
