SRCDIR=src/
LIBDIR=lib/

.PHONY: all compile serve clean

all: compile

compile:
	coffee --watch --output $(LIBDIR) $(SRCDIR)

serve:
	python -mSimpleHTTPServer

clean:
	rm -rf -- $(LIBDIR)
