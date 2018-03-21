CC=gcc
CFLAGS += -pthread -g -O0
LDFLAGS= -pthread 

all:

	$(CC) -c $(CFLAGS) -o test2.o test2.c
	$(CC) $(LDFLAGS) -o test2 ./test2.o
	$(CC) -c $(CFLAGS) -S test2.c

	$(CC) -c $(CFLAGS) -o invalidation_test_2core.o invalidation_test_2core.c
	$(CC) $(LDFLAGS) -o invalidation_test_2core ./invalidation_test_2core.o
	$(CC) -c $(CFLAGS) -S invalidation_test_2core.c

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
	-rm invalidation_test_2core
	-rm test2
