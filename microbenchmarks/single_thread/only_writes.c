/*
Write a value MAX times
*/

#define MAX 15

int a[MAX];
int temp;

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

int main() {
	INSTRUMENT_ON(); // Toggle on

	int i;

    for (i = 0; i < MAX; i++) {
        a[i] = 1;
    }

	INSTRUMENT_OFF(); // Toggle off
	return 0;
}