/*
Read a value MAX times
*/

#define MAX 1000

int a[MAX];
int read;
int temp;

int start_instrumentation() {
	// Need to set some var to keep from optimzing the function call away from -O1
	temp = 0;
	return 0;   
}

int main() {
	start_instrumentation(); // Toggle on

	int i;
	

    for (i = 0; i < MAX; i++) {
        read = a[i];
    }

	start_instrumentation(); // Toggle off
	return 0;
}