SRCDIR=src/
LIBDIR=lib/

.PHONY: all compile clean

all: compile

compile:
	coffee --watch --output $(LIBDIR) $(SRCDIR)

clean:
	rm -rf -- $(LIBDIR)
