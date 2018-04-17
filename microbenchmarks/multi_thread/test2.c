#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>

#define MAXVAL 16384
#define DOUBLEMAX MAXVAL*2
#define NUMTHREADS 2

int temp;
pthread_mutex_t lock;

struct wonk{ // should occupy a 64B cache line
  int a;
  char c[60];
};

struct wonk array[DOUBLEMAX];

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
    b = array[i].a;
    //array[i].a = array[i].a * 2;
  }
  
  INSTRUMENT_OFF();
  temp = b;
  pthread_mutex_unlock(&lock);
  pthread_exit(NULL); 
}


void *accessorThread2(void *arg){
  register int i;
  register int b;

  pthread_mutex_lock(&lock);
  
  INSTRUMENT_ON();
  for (i=MAXVAL; i < DOUBLEMAX; i++) {
    b = array[i].a;
    //array[i].a = array[i].a * 2;
  }
  
  INSTRUMENT_OFF();
  temp = b;
  pthread_mutex_unlock(&lock);
  pthread_exit(NULL); 
}


void *accessorThreadW(void *arg){
  register int i;
  register int b;

  pthread_mutex_lock(&lock);
  
  INSTRUMENT_ON();
  for (i=0; i < MAXVAL; i++) {
    array[i].a = i;
    //array[i].a = array[i].a * 2;
  }
  
  INSTRUMENT_OFF();
  temp = b;
  pthread_mutex_unlock(&lock);
  pthread_exit(NULL); 
}

int main(int argc, char *argv[]){


  pthread_t acc[2];
  pthread_mutex_init(&lock,NULL);
  register int i;
  register int b;

//    INSTRUMENT_ON();
//   for (i=0; i < MAXVAL; i++) {
//     b = array[i].a;
//   }
// //   
// //   for (i=MAXVAL; i < DOUBLEMAX; i++) {
// //     array[i].a = i;
// //   }
//    INSTRUMENT_OFF();
//   
//    temp = b;
   
   pthread_create(&acc[0],NULL,accessorThread,(void *)&array);
   pthread_join(acc[0],NULL);
   
   
   pthread_create(&acc[1],NULL,accessorThread,(void *)&array);
   pthread_join(acc[1],NULL);
   
   
   
   pthread_create(&acc[0],NULL,accessorThread2,(void *)&array);
   pthread_join(acc[0],NULL);
   
   
   pthread_create(&acc[1],NULL,accessorThreadW,(void *)&array);
   pthread_join(acc[1],NULL);
   

//     pthread_create(&acc[0],NULL,accessorThread,(void *)&array);
//    pthread_join(acc[0],NULL);
 
    



  return 0;
}
