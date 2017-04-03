%{  
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
int linecount=0;
#include "y.tab.h"
#include "y.tab.c"

int open=0,no_opened=0,scope=-1;
int for_flag = 0, brack = 0;
char *text;
int numtext;
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
        return RETURN;
       }
void {  
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext);
        return VOID;
    }
int {
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext); 
        return INT;
    }
char {
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext); 
        return CHAR;
    }
float {
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext); 
        return FLOAT;
    }
main {
        printf("line: %d token type: keyword token text:(%s)\n",linecount,yytext); 
        text = malloc(sizeof(yytext)+1);
        strcpy(text,yytext);
        return MAIN;
        }
if {
    printf("line: %d token type: keyword token text:(if)\n",linecount); 
    return IF;
    }
for {   
        for_flag = 1;
        printf("line: %d token type: keyword token text:(for)\n",linecount); 
        return FOR;
        }
else {
        printf("line: %d token type: keyword token text:(else)\n",linecount); 
        return ELSE;
        }
"break" {
            if(!(for_flag && brack)) {
                printf("ERROR : BREAK not inside loop\n");
                exit(1);
            }
            printf("line: %d token type: keyword token text:(break)\n",linecount);
            return BREAK;
            } 
"continue" {
            if(!(for_flag && brack)) {
                printf("ERROR : CONTINUE not inside loop\n");
                exit(1);
            }
            printf("line: %d token type: keyword token text:(continue)\n",linecount);
            return CONTINUE;
            } 

[\{]    {           if (for_flag == 0) {
                        open+=1;
                    }
                    else if(for_flag == 1)
                        brack++;
                    printf("line: %d token type: seperator token text:(%s)\n",linecount,yytext); 
                    return *yytext;
                    }
[\}]    {           
                    if(for_flag == 0) {
                        if (open == 0) {
                            printf("SYNTAX ERROR - Unmatched '}'.\n");
                            exit(0);
                        }
                        else {
                            open-=1;
                        }
                    }
                    else if(for_flag == 1)
                        {
                            brack--;
                            if(brack==0)
                                for_flag = 0;
                        }
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
    yylval.op_val = yytext;
    return NOT_OP;
    }
== {
    printf("line: %d token type: equal to operator token text:(%s)\n",linecount,yytext); 
    yylval.op_val = yytext;
    return EE_OP;
    }
\> {
    printf("line: %d token type: greater than operator token text:(%s)\n",linecount,yytext); 
    yylval.op_val = yytext;
    return G_OP;
    }
\< {
    printf("line: %d token type: lesser than operator token text:(%s)\n",linecount,yytext); 
    yylval.op_val = yytext;
    return L_OP;
    }
\>= {
    printf("line: %d token type: greater than equal to operator token text:(%s)\n",linecount,yytext);
    yylval.op_val = yytext;
    return GE_OP;
    }
\<= {
        printf("line: %d token type: lesser than equal to operator token text:(%s)\n",linecount,yytext); 
        yylval.op_val = yytext;
        return LE_OP;
        }
\!= {
        printf("line: %d token type: not equal to operator token text:(%s)\n",linecount,yytext); 
        yylval.op_val = yytext;
        return NE_OP;
        }

= {
        printf("line: %d token type: equal to operator token text:(%s)\n",linecount,yytext); 
        yylval.op_val = yytext; 
        return ASSIGN_OP;
     } 
\+ {
        printf("line: %d token type: + operator token text:(%s)\n",linecount,yytext); 
        yylval.op_val = yytext;
        return ADD_OP;
     } 
\- {
        printf("line: %d token type: - operator token text:(%s)\n",linecount,yytext); 
        yylval.op_val = yytext;
        return SUB_OP;
     } 
\* {
        printf("line: %d token type: * operator token text:(%s)\n",linecount,yytext); 
        yylval.op_val = yytext;
        return MUL_OP;
     } 
\/ {
        printf("line: %d token type: / operator token text:(%s)\n",linecount,yytext); 
        yylval.op_val = yytext;
        return DIV_OP;
     } 

[_a-zA-Z][_a-zA-Z0-9]* {
                         text = malloc(sizeof(yytext)+1);
                         strcpy(text,yytext);                     
                        if(open==0)
                            {
                            printf("line: %d token type: identifier token text scope - global:(%s)\n",linecount,yytext);
                            scope=0;
                            }
                        else
                            {
                            scope = open;
                            printf("line: %d token type: identifier token text scope - local at level %d :(%s)\n",linecount,scope,yytext);
                            }
                        return IDENTIFIER;
                        }
[0-9]+[\.][0-9][0-9]* { 
                            yylval.real_val = atof(yytext);
                            return DOUBLE;
                        }
[\+-][0-9]+[\.][0-9][0-9]* {
                            yylval.real_val = atof(yytext);
                            return DOUBLE;
                        }
[\+\-][0-9][0-9]*[eE][\+-][0-9][0-9]* {
                                        yylval.real_val = atof(yytext);
                                        return DOUBLE;
                                    }
[0-9][0-9]* {
                yylval.int_val = atoi(yytext);
                numtext = yylval.int_val; 
                return INTEGER;
                }
                

[\+\-][0-9][0-9]* {
                    yylval.int_val = atoi(yytext);
                    numtext = yylval.int_val; 
                    return INTEGER;
                }

[\'].{1}[\'] {
                printf("line: %d token type: Character text:(%s)\n",linecount,yytext);
                return CHARACTER;
                }
[\'][\\][0][\'] {
                printf("line: %d token type: Character text:(%s)\n",linecount,yytext);
                return CHARACTER;
                }

\"([^"])*\" {
                printf("line: %d token type: string literal text:(%s)\n",linecount,yytext); 
                return STRINGLITERAL;
                }
\n {linecount++;}
%%

int yywrap(void) {
return 1;
}
