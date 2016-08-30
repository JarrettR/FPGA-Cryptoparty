GCC=gcc -pipe -g

all: fx2demo

fx2demo: fx2demo.c
	$(GCC) fx2demo.c -lusb -o fx2demo

clean:
	rm -f *.o *.old *.bak *~

distclean:
	rm -f fx2demo
