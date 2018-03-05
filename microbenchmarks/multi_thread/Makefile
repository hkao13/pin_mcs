CC=gcc
CFLAGS += -pthread -g -O1
LDFLAGS= -pthread 

all:
	$(CC) -c $(CFLAGS) -o mt_test.o mt_test.c
	$(CC) $(LDFLAGS) -o mt_test ./mt_test.o
	$(CC) -c $(CFLAGS) -S mt_test.c

	$(CC) -c $(CFLAGS) -o simple.o simple.c
	$(CC) $(LDFLAGS) -o simple ./simple.o
	$(CC) -c $(CFLAGS) -S simple.c

clean:
	-rm *.o
	-rm *.s
	-rm mt_test
	-rm simple
