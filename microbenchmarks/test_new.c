#include <stdio.h>
#include <stdlib.h>

#define KILO 1024
#define MEGA KILO*KILO
#define GIGA KILO*MEGA

#define as 128*KILO //array size

void start_instrumentation() {
    //printf("Hello world!\n");
  }

struct block{
	int32_t a[8];};

typedef struct block block_t;

int main(){
	block_t array[as];
	
	register int i;
	
	int32_t j;
	
	for (i=0; i<as; i++){
		if (i==1){
			start_instrumentation();
		}
		array[i].a[1] = array[i].a[1] + 1;
		if (i==as-1){
			start_instrumentation();
		}
	}
	/*for (i=0; i<as; i++){		
		array[i].a[1] = array[i].a[1] + 1;
		//j = array[i].a[1];
		printf("%d", array[i].a[1]);
	}*/
	
	return 0;
}

