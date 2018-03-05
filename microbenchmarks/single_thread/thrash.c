/*
Read from array b and c, then write to array a.
*/

#define MAX 1024 * 1024

int a[MAX];
int b[MAX];
int c[MAX];
int d[MAX];
int e[MAX];

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
        a[i] = b[i] * c[i] + d[i] - e[i];
    }

	start_instrumentation(); // Toggle off
	return 0;
}