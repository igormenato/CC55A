# Compilador - Calculadora Avancada com Flex/Bison
# Trabalho Pratico 1 - Compiladores 2026.1

CC = gcc
CFLAGS = -Wall -g
LDFLAGS = -lm

SRCDIR = src
TARGET = calc
OBJS = $(SRCDIR)/lex.yy.o $(SRCDIR)/bison-calc.tab.o $(SRCDIR)/calc_aux.o

.PHONY: all clean test

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(SRCDIR)/lex.yy.c: $(SRCDIR)/lexer.l $(SRCDIR)/bison-calc.tab.h
	flex -o $@ $<

$(SRCDIR)/bison-calc.tab.c $(SRCDIR)/bison-calc.tab.h: $(SRCDIR)/parser.y
	bison -d -o $(SRCDIR)/bison-calc.tab.c $<

$(SRCDIR)/lex.yy.o: $(SRCDIR)/lex.yy.c $(SRCDIR)/bison-calc.h $(SRCDIR)/bison-calc.tab.h
	$(CC) $(CFLAGS) -c -o $@ $<

$(SRCDIR)/bison-calc.tab.o: $(SRCDIR)/bison-calc.tab.c $(SRCDIR)/bison-calc.h
	$(CC) $(CFLAGS) -c -o $@ $<

$(SRCDIR)/calc_aux.o: $(SRCDIR)/calc_aux.c $(SRCDIR)/bison-calc.h
	$(CC) $(CFLAGS) -c -o $@ $<

test: $(TARGET)
	cd tests && bash run_tests.sh

clean:
	rm -f $(TARGET) $(OBJS) $(SRCDIR)/lex.yy.c $(SRCDIR)/bison-calc.tab.c $(SRCDIR)/bison-calc.tab.h
