make: 
	lex c_lexer.l
	yacc -d c_parser.y
	gcc lex.yy.c y.tab.h -ll
	./a.out test.c
