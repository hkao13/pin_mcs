#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>

#define MAXVAL 2000
#define NUMTHREADS 2

int temp;

struct wonk{
  int a;
  char c[60];
};

struct wonk array[MAXVAL];

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
  register int i;
  
  INSTRUMENT_ON();
  for (i=0; i < MAXVAL; i++) {
    array[i].a = array[i].a * array[i].a;
  }
  INSTRUMENT_OFF();

  pthread_exit(NULL); 
}

int main(int argc, char *argv[]){



  pthread_t acc[2];
  register int i;
  INSTRUMENT_ON();
  for (i=0; i < MAXVAL; i++) {
    array[i].a = i;
  }
  INSTRUMENT_OFF();
  
  pthread_create(&acc[0],NULL,accessorThread,(void *)&array);
  pthread_create(&acc[1],NULL,accessorThread,(void *)&array);

  pthread_join(acc[0],NULL);
  pthread_join(acc[1],NULL);

  return 0;
}
