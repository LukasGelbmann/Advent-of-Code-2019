CC = gcc
CFLAGS = -std=c99 -O2 -flto -pedantic -Wall
LDLIBS = -lm
ifeq ($(debug), 1)
    # -Wno-unknown-warning-option is given so that a user can specify both
    # CC=clang and debug=1 as command-line arguments at the same time.
    # -Wunreachable-code has no effect in gcc, but in clang it does.
    CFLAGS += \
        -g -save-temps=obj \
        -fsanitize=address,float-cast-overflow,float-divide-by-zero,undefined \
        -Wno-unknown-warning-option -Wno-type-limits -Werror -Wextra \
        -Wbad-function-cast -Wcast-align=strict -Wcast-qual -Wconversion \
        -Wdouble-promotion -Wduplicated-branches -Wduplicated-cond -Wformat=2 \
        -Winit-self -Winline -Winvalid-pch -Wjump-misses-init \
        -Wlogical-not-parentheses -Wlogical-op -Wmissing-declarations \
        -Wmissing-format-attribute -Wmissing-include-dirs \
        -Wmissing-prototypes -Wnested-externs -Wnull-dereference \
        -Wold-style-definition -Wredundant-decls -Wshadow -Wstrict-overflow=2 \
        -Wstrict-prototypes -Wundef -Wunreachable-code -Wwrite-strings
endif

programs := $(sort $(wildcard d[0-9][0-9]*.c))
stems := $(programs:%.c=%)
bins := $(stems:%=bin/%)
objs := $(programs:%.c=obj/%.o)

module_headers := $(sort $(wildcard *.h))
module_objs := $(module_headers:%.h=obj/%.o)

labels := $(foreach stem,$(stems),$(firstword $(subst _, ,$(stem))))
days := $(subst d,,$(labels))
days += $(patsubst 0%,%,$(filter 0%,$(days)))


.PHONY: all run $(days) test time clean

all: $(bins)

# The mv command is for compatibility with Windows.
$(bins): bin/%: obj/%.o $(module_objs) | bin
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)
	@[ ! -e $@.exe ] || mv $@.exe $@

$(objs) $(module_objs): obj/%.o: %.c $(module_headers) | obj
	$(CC) $(CFLAGS) -c -o $@ $<

run: $(bins)
	@sh run.sh

$(days): $(bins)
	@sh run.sh $@

test: $(bins)
	@sh test/run_all.sh

time: $(bins)
	@sh run.sh --time

bin obj:
	mkdir $@

clean:
	rm -f bin/* obj/*
