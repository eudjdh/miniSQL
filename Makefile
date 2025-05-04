SRCDIR    := src
BUILDDIR  := build
BINDIR    := bin

LEX       := flex
YACC      := bison
CC        := gcc
CFLAGS    := -Wall

LEX_SRC   := $(SRCDIR)/myLexer.l
YACC_SRC  := $(SRCDIR)/myParser.y

LEX_C     := $(BUILDDIR)/lex.yy.c
YACC_C    := $(BUILDDIR)/parser.tab.c
YACC_H    := $(BUILDDIR)/parser.tab.h

LEX_O     := $(BUILDDIR)/lex.yy.o
YACC_O    := $(BUILDDIR)/parser.tab.o

TARGET    := $(BINDIR)/miniSQL

.PHONY: clean run

directories:
	@mkdir -p $(BUILDDIR) $(BINDIR)

$(YACC_C) $(YACC_H): $(YACC_SRC)
	$(YACC) -d -o $(YACC_C) $<

$(LEX_C): $(LEX_SRC)
	$(LEX) -o $(LEX_C) $<

$(YACC_O): $(YACC_C) $(YACC_H)
	$(CC) $(CFLAGS) -c $(YACC_C) -o $(YACC_O)

$(LEX_O): $(LEX_C) $(YACC_H)
	$(CC) $(CFLAGS) -c $(LEX_C) -o $(LEX_O)

$(TARGET): $(YACC_O) $(LEX_O)
	$(CC) $(CFLAGS) $^ -o $@ -lfl

clean:
	-rm -rf $(BUILDDIR) $(BINDIR)

run: directories $(TARGET)
	$(BINDIR)/miniSQL
