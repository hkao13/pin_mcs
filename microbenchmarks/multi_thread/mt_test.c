#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>

#define MAXVAL 8
#define NUMTHREADS 2

int temp;

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

void *accessorThread(void *arg){

  

  struct wonk *thread_data;

  thread_data = (struct wonk *) arg;
  int* array;
  array = thread_data -> a;

  int i;

  
  INSTRUMENT_ON();
  for (i=0; i < MAXVAL; i++) {

    //array[i] = array[i] * array[i];
    array[i] = 100;
  }

  INSTRUMENT_OFF();

  pthread_exit(NULL); 
}

int main(int argc, char *argv[]){

  INSTRUMENT_ON();

  pthread_t acc[2];

  pthread_create(&acc[0],NULL,accessorThread,(void *)&wonk_array[0]);
  pthread_create(&acc[1],NULL,accessorThread,(void *)&wonk_array[1]);

  pthread_join(acc[0],NULL);
  pthread_join(acc[1],NULL);

  INSTRUMENT_OFF();

  

  return 0;

}
