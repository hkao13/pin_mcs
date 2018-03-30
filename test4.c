#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>

#define MAXVAL 4096
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

void *accessorThread1(void *arg){
  register int i;
  register int b;

  pthread_mutex_lock(&lock);
  
  INSTRUMENT_ON();


  for (i=0; i < MAXVAL*2; i++) {
    array[i].a = i;
  }
  

  //for (i=MAXVAL; i < 2*MAXVAL; i++) {
  //  b = array[i].a;
  //}

  
  INSTRUMENT_OFF();

  hold = b;

  pthread_mutex_unlock(&lock);

  pthread_exit(NULL); 
}

void *accessorThread2(void *arg){
  register int i;
  register int b;
  

  pthread_mutex_lock(&lock);
  
  INSTRUMENT_ON();

  for (i=0; i < MAXVAL; i++) {
    b = array[i].a;
  }


   for (i=MAXVAL; i < 2*MAXVAL; i++) {
     b = array[i].a;
   }

  INSTRUMENT_OFF();

  hold = b;

  pthread_mutex_unlock(&lock);

  pthread_exit(NULL); 
}

int main(int argc, char *argv[]){


  pthread_t acc[2];
  pthread_mutex_init(&lock,NULL);
  register int i;
  register int c;
  
  INSTRUMENT_ON();
  for (i=0; i < MAXVAL*2; i++) {
    array[i].a = i;
  }
  //for (i=0; i < MAXVAL*2; i++) {
  //  c = array[i].a;
  //}
  INSTRUMENT_OFF();
  //for (i=MAXVAL; i < MAXVAL*2; i++) {
  //  c = array[i].a;
  //}
  usleep(1000);
  

  pthread_create(&acc[0],NULL,accessorThread1,(void *)&array);
  pthread_join(acc[0],NULL);



  INSTRUMENT_ON();
  for (i=0; i < MAXVAL*2; i++) {
    c = array[i].a;
  }
  INSTRUMENT_OFF();
  hold = c;


  //pthread_create(&acc[1],NULL,accessorThread2,(void *)&array);
  //pthread_join(acc[1],NULL);

  return 0;
}
