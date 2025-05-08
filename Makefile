SRCDIR    	:= src
BUILDDIR  	:= build
DATABASEDIR	:= database
BINDIR    	:= bin
INCLUDEDIR	:= include  # 新增头文件目录变量

LEX       	:= flex
YACC      	:= bison
CC        	:= gcc
CFLAGS    	:= -Wall -I$(INCLUDEDIR) -I$(BUILDDIR)  # 添加头文件搜索路径

LEX_SRC   	:= $(SRCDIR)/myLexer.l
YACC_SRC  	:= $(SRCDIR)/myParser.y

DB_C		:= $(SRCDIR)/db.c
LEX_C     	:= $(BUILDDIR)/lex.yy.c
YACC_C    	:= $(BUILDDIR)/parser.tab.c
YACC_H    	:= $(BUILDDIR)/parser.tab.h

DB_O		:= $(BUILDDIR)/db.o
LEX_O     	:= $(BUILDDIR)/lex.yy.o
YACC_O    	:= $(BUILDDIR)/parser.tab.o

TARGET    	:= $(BINDIR)/miniSQL

.PHONY: clean run

directories:
	@mkdir -p $(BUILDDIR) $(BINDIR)
	@mkdir -p $(DATABASEDIR)

databasefile:
	@touch $(DATABASEDIR)/sys.dat

$(YACC_C) $(YACC_H): $(YACC_SRC)
	$(YACC) -d -o $(YACC_C) $<

$(LEX_C): $(LEX_SRC)
	$(LEX) -o $(LEX_C) $<

$(YACC_O): $(YACC_C) $(YACC_H)
	$(CC) $(CFLAGS) -c $(YACC_C) -o $(YACC_O)

$(LEX_O): $(LEX_C) $(YACC_H)
	$(CC) $(CFLAGS) -c $(LEX_C) -o $(LEX_O)

$(DB_O): $(DB_C)
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(YACC_O) $(LEX_O) $(DB_O)
	$(CC) $(CFLAGS) $^ -o $@ -lfl

clean:
	-rm -rf $(BUILDDIR) $(BINDIR) $(DATABASEDIR)

run: directories databasefile $(TARGET)
	$(BINDIR)/miniSQL
