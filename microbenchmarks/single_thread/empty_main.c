/*
Empty benchmark, consistency check.
*/

int temp;
int fasdf;
int temp2 = 0xffff;

void INSTRUMENT_ON() {
  // Need to set some var to keep from optimzing the function call away from -O1
  //temp = 11;
  //return 0;  
}

void INSTRUMENT_OFF() {
  // Need to set some var to keep from optimzing the function call away from -O1
  //temp = 22;
  //return 0;  
}

int main() {
	INSTRUMENT_ON();
	temp = temp2;
	INSTRUMENT_OFF();
	return 0;
}