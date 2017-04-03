make: 
	lex lexer.l
	yacc -d parser.y
	gcc lex.yy.c y.tab.h -ll
	./a.out test.c
