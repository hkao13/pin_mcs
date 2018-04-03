#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>

#define MAXVAL 16
#define NUMTHREADS 2

int hold;
int temp;
pthread_mutex_t lock;

struct wonk{ // should occupy a 64B cache line
  int a;
  char c[60];
};

struct wonk array[MAXVAL*2];

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
  register int b;

  pthread_mutex_lock(&lock);
  
  INSTRUMENT_ON();

  for (i=0; i < MAXVAL; i++) {
    array[i].a = (i%5);
  }
  
  
  INSTRUMENT_OFF();

  pthread_mutex_unlock(&lock);

  pthread_exit(NULL); 
}


int main(int argc, char *argv[]){


  pthread_t acc[2];
  pthread_mutex_init(&lock,NULL);
  register int i;
  register int c;

  INSTRUMENT_ON();
  for (i=0; i < MAXVAL; i++) {
    array[i].a = i;
  }
  INSTRUMENT_OFF();


  pthread_create(&acc[0],NULL,accessorThread,(void *)&array);
  pthread_join(acc[0],NULL);


  INSTRUMENT_ON();
  for (i=0; i < MAXVAL; i++) {
    c = array[i].a;
  }
  INSTRUMENT_OFF();
  hold = c;

  return 0;
}