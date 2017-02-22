%{  
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
int linecount=0;
#include "y.tab.h"
#include "y.tab.c"

int open=0,scope=0;

void yyerror(char *);
%}

%%
[ ][ ]* ;
\/\/.*[\n] {linecount++;}
"/*"([^*]|\*+[^*/])*\*+"/" {    
                                int i = 0;
                                for(i = 0; i < strlen(yytext); i++)
                                {
                                    if(yytext[i] == '\n')
                                        linecount++;
                                }
                            }

return {
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,RETURN,yytext,0);
        return RETURN;
       }
void {  
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext);
        head = insert_node(&head,VOID,yytext,0);
        return VOID;
    }
int {
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,INT,yytext,0);
        return INT;
    }
char {
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,CHAR,yytext,0);
        return CHAR;
    }
float {
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,FLOAT,yytext,0);
        return FLOAT;
    }
main {
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,MAIN,yytext,0);
        return MAIN;
        }
if {
    printf("line: %d token type: keyword token text:(if)\n",linecount); 
    head = insert_node(&head,IF,yytext,0);
    return IF;
    }
for {
        printf("line: %d token type: keyword token text:(for)\n",linecount); 
        head = insert_node(&head,FOR,yytext,0);
        return FOR;
        }
else {
        printf("line: %d token type: keyword token text:(else)\n",linecount); 
        head = insert_node(&head,ELSE,yytext,0);
        return ELSE;
        }
break {
            printf("line: %d token type: keyword token text:(break)\n",linecount);
            head = insert_node(&head,BREAK,yytext,0);
            return BREAK;
            } 
continue {
            printf("line: %d token type: keyword token text:(continue)\n",linecount);
            head = insert_node(&head,CONTINUE,yytext,0);
            return CONTINUE;
            } 

[\{]    {           open=1;
                    printf("line: %d token type: seperator token text:(%s)\n",linecount,yytext); 
                    return *yytext;
                    }
[\}]    {           open=0;
                    printf("line: %d token type: seperator token text:(%s)\n",linecount,yytext); 
                    return *yytext;
                    }
                                
[,;\(\)\[\]] {
                    printf("line: %d token type: seperator token text:(%s)\n",linecount,yytext); 
                    return *yytext;
                    }
#.* {
        printf("line: %d token type: and preprocessor directive text:(%s)\n",linecount,yytext);
    }

\! {
    printf("line: %d token type: not operator token text:(%s)\n",linecount,yytext);
    head = insert_node(&head,NOT_OP,yytext,0); 
    yylval.op_val = yytext;
    return NOT_OP;
    }
== {
    printf("line: %d token type: equal to operator token text:(%s)\n",linecount,yytext);
    head = insert_node(&head,EE_OP,yytext,0); 
    yylval.op_val = yytext;
    return EE_OP;
    }
\> {
    printf("line: %d token type: greater than operator token text:(%s)\n",linecount,yytext); 
    head = insert_node(&head,G_OP,yytext,0);
    yylval.op_val = yytext;
    return G_OP;
    }
\< {
    printf("line: %d token type: lesser than operator token text:(%s)\n",linecount,yytext); 
    head = insert_node(&head,L_OP,yytext,0);
    yylval.op_val = yytext;
    return L_OP;
    }
\>= {
    printf("line: %d token type: greater than equal to operator token text:(%s)\n",linecount,yytext);
    head = insert_node(&head,GE_OP,yytext,0); 
    yylval.op_val = yytext;
    return GE_OP;
    }
\<= {
        printf("line: %d token type: lesser than equal to operator token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,LE_OP,yytext,0);
        yylval.op_val = yytext;
        return LE_OP;
        }
\!= {
        printf("line: %d token type: not equal to operator token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,NE_OP,yytext,0);
        yylval.op_val = yytext;
        return NE_OP;
        }

[=] {
        printf("line: %d token type: not equal to operator token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,ASSIGN_OP,yytext,0);
        yylval.op_val = yytext; 
        return ASSIGN_OP;
     } 
\+ {
        printf("line: %d token type: not equal to operator token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,ADD_OP,yytext,0);
        yylval.op_val = yytext;
        return ADD_OP;
     } 
\- {
        printf("line: %d token type: not equal to operator token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,SUB_OP,yytext,0);
        yylval.op_val = yytext;
        return SUB_OP;
     } 
\* {
        printf("line: %d token type: not equal to operator token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,MUL_OP,yytext,0);
        yylval.op_val = yytext;
        return MUL_OP;
     } 
\/ {
        printf("line: %d token type: not equal to operator token text:(%s)\n",linecount,yytext); 
        head = insert_node(&head,DIV_OP,yytext,0);
        yylval.op_val = yytext;
        return DIV_OP;
     } 

[_a-zA-Z][_a-zA-Z0-9]* {
                        if(open==0)
                            {
                            printf("line: %d token type: identifier token text scope - global:(%s)\n",linecount,yytext);
                            scope=1;
                            }
                        else
                            {
                            printf("line: %d token type: identifier token text scope - local:(%s)\n",linecount,yytext);
                            scope=2;
                            }
                        head = insert_node(&head,IDENTIFIER,yytext,scope); 
                        return IDENTIFIER;
                        }
[0-9]+[\.][0-9][0-9]* { 
                            yylval.real_val = atof(yytext);
                            printf("%f has been read\n", yylval.real_val);
                            head = insert_node(&head,DOUBLE,yytext,0);
                            return DOUBLE;
                        }
[\+-][0-9]+[\.][0-9][0-9]* {
                            yylval.real_val = atof(yytext);
                            printf("%f has been read\n", yylval.real_val);
                            head = insert_node(&head,DOUBLE,yytext,0);
                            return DOUBLE;
                        }
[\+\-][0-9][0-9]*[eE][\+-][0-9][0-9]* {
                                        yylval.real_val = atof(yytext);
                                        printf("%f has been read\n", yylval.real_val);
                                        head = insert_node(&head,DOUBLE,yytext,0);
                                        return DOUBLE;
                                    }
[0-9][0-9]* {
                yylval.int_val = atoi(yytext); 
                printf("%d has been read\n", yylval.int_val);
                head = insert_node(&head,INTEGER,yytext,0);
                return INTEGER;
                }
                


[\+\-][0-9][0-9]* {
                    yylval.int_val = atoi(yytext);
                    printf("%d has been read\n", yylval.int_val);
                    head = insert_node(&head,INTEGER,yytext,0);
                    return INTEGER;
                }

[\'].{1}[\'] {
                printf("line: %d token type: Character text:(%s)\n",linecount,yytext);
                head = insert_node(&head,CHARACTER,yytext,0);
                return CHARACTER;
                }
[\'][\\][0][\'] {
                printf("line: %d token type: Character text:(%s)\n",linecount,yytext);
                head = insert_node(&head,CHARACTER,yytext,0);
                return CHARACTER;
                }

\"([^"])*\" {
                printf("line: %d token type: string literal text:(%s)\n",linecount,yytext); 
                head = insert_node(&head,STRINGLITERAL,yytext,0);
                return STRINGLITERAL;
                }
\n {linecount++;}
%%

int yywrap(void) {
return 1;
}
