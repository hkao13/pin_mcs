/*
Read from array b and write to array a.
*/

#define MAX 1000

int a[MAX];
int b[MAX];

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
        a[i] = b[i];
    }

	start_instrumentation(); // Toggle off
	return 0;
}