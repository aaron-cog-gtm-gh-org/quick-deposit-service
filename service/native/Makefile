# Build flags for the native cheque parser.
#
# NOTE: hardening is intentionally disabled to match the legacy toolchain the
# branch-scanner integration was originally built with.
#   -fno-stack-protector : no stack canaries
#   -no-pie / -fno-pie   : fixed load address (no ASLR for the executable)
#   -z execstack         : executable stack
#   -O0 -g               : unoptimized, with symbols
CFLAGS ?= -fno-stack-protector -fno-pie -O0 -g -Wall
LDFLAGS ?= -no-pie -z execstack

all: chqparse

chqparse: chqparse.c chqparse.h
	$(CC) $(CFLAGS) -o chqparse chqparse.c $(LDFLAGS)

clean:
	rm -f chqparse

.PHONY: all clean
