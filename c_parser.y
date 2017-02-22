%{
    #include <stdio.h>
    void yyerror(char *s);
    extern char *yytext;
    extern int yylex();
    extern int yyparse();
    struct entry {
                int token_type;
                char data_type[30];
                char* token_name;
                char* scope;
                struct entry *next;
     }*node;
     struct entry* head = NULL;
%}

%union{
  int   int_val;
  char*	op_val;
  float real_val;
}

%token INTEGER DOUBLE CHARACTER IDENTIFIER STRINGLITERAL FLOAT CHAR
%token RETURN VOID INT MAIN IF FOR ELSE BREAK CONTINUE
%token ADD_OP SUB_OP MUL_OP DIV_OP GE_OP EE_OP NE_OP LE_OP L_OP G_OP NOT_OP ASSIGN_OP

%left ADD_OP SUB_OP MUL_OP DIV_OP GE_OP EE_OP NE_OP LE_OP L_OP G_OP NOT_OP
%right ASSIGN_OP
%nonassoc "then"
%nonassoc ELSE


%%

function
    : INT IDENTIFIER '(' ')' '{' statementlist '}' mainfunction
    | INT IDENTIFIER '(' INT IDENTIFIER')' '{' statementlist '}' mainfunction
    | mainfunction
    ;

mainfunction
	: INT MAIN '(' ')' '{' statementlist '}' 
	| VOID MAIN '(' ')' '{' statementlist '}'
	;

statementlist
    : statement
    | statement statementlist
    ;

statement
	: expressionstatement
	| returnstatement
    	| forstatement
    	| conditionalstatement
	| compoundstatement
	| declerationstatement
	| jumpstatement
	| functioncallstatement
	;

declerationstub
	: IDENTIFIER
	| arrayindex
	| IDENTIFIER ASSIGN_OP float_expression
	| arrayindex ASSIGN_OP float_expression
	;

c_declerationstub
	: IDENTIFIER
	| arrayindex
	| IDENTIFIER ASSIGN_OP CHARACTER
	| arrayindex ASSIGN_OP STRINGLITERAL
	;

declerationstatement
	: INT declerationstub declerationlist ';'
	| FLOAT declerationstub declerationlist ';'
	| CHAR c_declerationstub c_declerationlist ';'
	;

declerationlist
	: ',' declerationstub declerationlist
	|
	;

c_declerationlist
	:',' c_declerationstub c_declerationlist
	|
	;

compoundstatement
	: '{' '}'
	| '{' statementlist '}'
	;

conditionalstatement
	: IF '(' float_expression ')' statement %prec "then"
	| IF '(' float_expression ')' statement ELSE  statement 
	;

functioncallstatement
    : IDENTIFIER '(' ')' ';'
    | IDENTIFIER '(' float_expression ')' ';'
    | IDENTIFIER '(' STRINGLITERAL ')' ';'
    ;

jumpstatement
    : BREAK ';'
    | CONTINUE ';'
    ;

returnstatement
	: RETURN expression ';'	
	;

forstatement
	: FOR '(' optionalexpressionstatement ';' optionalexpressionstatement ';' optionalexpressionstatement ')' statement
	;


optionalexpressionstatement
    :
	| float_expression
	| float_expression ',' float_expression
	;  


expressionstatement
	: float_expression ';' 
	| float_expression ',' expressionstatement ';'
	;  

float_expression
    	: DOUBLE
    	| expression
    	| '(' float_expression ')'
    	| IDENTIFIER ASSIGN_OP float_expression 
	| arrayindex ASSIGN_OP float_expression	
	| float_expression ADD_OP float_expression
	| float_expression SUB_OP float_expression
	| float_expression MUL_OP float_expression
	| float_expression DIV_OP float_expression
	| float_expression G_OP float_expression
	| float_expression L_OP float_expression
	| float_expression GE_OP float_expression
	| float_expression LE_OP float_expression
	| float_expression EE_OP float_expression
	| float_expression NE_OP float_expression
	| float_expression NOT_OP float_expression
    	;

expression
	: INTEGER
	| IDENTIFIER
    	| arrayindex
	;

arrayindex
	: IDENTIFIER '[' expression ']'
	;

%%

int error_flag = 0;

void yyerror(char *s) {
    error_flag = 1;
    fprintf(stderr, "%s %s \n", s, yytext);
}



//Symbol Table
int search_symbol(struct entry** head, char* token_name,char *scope)
{
    int flag=0;
    struct entry* temp = *head;
    while(temp!=NULL)
    {
        if(strcmp(temp->token_name,token_name)==0 && strcmp(temp->scope,scope)==0)
        {
            flag=1;
            break;
        }
        temp=temp->next;
    }
    if(flag) {
         return flag;
    }
    else {
        return flag;
    }
}

struct entry* insert_node(struct entry** head,int ntoken, char* yytext,int scope) {
    node = (struct entry*)malloc(sizeof(struct entry));
    node->token_type = ntoken;
    node->scope = malloc(7);
    if(scope==0)
        node->scope="NA";
     else if(scope==1)
        node->scope="global";
     else
        node->scope="local";
    node->token_name = malloc(strlen(yytext)+1);
    strcpy(node->token_name, yytext);
    node->next = NULL;
    yytext = NULL;
    int flag = search_symbol(head, node->token_name,node->scope);
    if(!(flag)) {
        if (*head == NULL) {
            *head = node;
            return *head;
        }
        else {
            struct entry * temp = *head;
            while(temp->next != NULL) {
                temp = temp -> next;
            }
            temp->next = node;
            return *head;
        }
    }
    else {
        return *head;
    }
}
void display_table(struct entry* head)
{
    FILE *fptr;
    fptr = fopen("symbol_table.txt","w");
    if(fptr == NULL)
     {
      printf("Error!");
      exit(1);
     }
    fprintf(fptr,"\nSYMBOL TABLE:\n________________________\n\n|TOKEN TYPE |TOKEN NAME |SCOPE|\n________________________\n");
    struct entry* temp = head;
    while(temp!=NULL)
    {
        switch(temp->token_type) {
            case INTEGER:
            case DOUBLE:
            case CHARACTER:
            case STRINGLITERAL: fprintf(fptr,"%s\t%s\t\t\t%s\n","CONSTANT",temp->token_name,temp->scope);
                                break;
            
            case IDENTIFIER: fprintf(fptr,"%s\t%s\t\t\t%s\n","IDENTIFIER",temp->token_name,temp->scope);
                             break;

            
            case FLOAT:
            case CHAR:
            case VOID:
            case INT: fprintf(fptr,"%s\t%s\t\t\t%s\n","DATA_TYPE",temp->token_name,temp->scope);
                      break;
            
            case RETURN:
            case MAIN:
            case IF:
            case FOR:
            case ELSE: fprintf(fptr,"%s\t\t%s\t\t\t%s\n","KEYWORD",temp->token_name,temp->scope);
                       break;
            
            case BREAK:
            case CONTINUE: fprintf(fptr,"%s\t%s\t\t\t%s\n","JUMP_STMT",temp->token_name,temp->scope);
                           break;
            
            case ADD_OP:
            case SUB_OP:
            case MUL_OP:
            case DIV_OP: fprintf(fptr,"%s\t%s\t\t\t%s\n","ARITH_OP",temp->token_name,temp->scope);
            break;
            
            case GE_OP:
            case EE_OP:
            case NE_OP:
            case LE_OP:
            case L_OP:
            case G_OP:  fprintf(fptr,"%s\t%s\t\t\t%s\n","REL_OP",temp->token_name,temp->scope);
            break;
            
            case NOT_OP: fprintf(fptr,"%s\t%s\t\t\t%s\n","LOGICAL_OP",temp->token_name,temp->scope);
            break;
            
            case ASSIGN_OP: fprintf(fptr,"%s\t%s\t\t\t%s\n","ASSIGN_OP",temp->token_name,temp->scope);
            break;
        }   
        
        temp=temp->next;
    }
        fclose(fptr);

}

int main(argc,argv)
int argc;
char** argv;
{           
if (argc > 1)
{
    FILE *file;
    file = fopen(argv[1], "r");
    if (!file)
    {
        fprintf(stderr, "Could not open %s\n", argv[1]);
        exit(1);
    }
    yyin = file;
}
yyparse();

if(error_flag == 0) {
    printf("FILE HAS NO SYNTAX ERRORS\n");
}

display_table(head);
return 0;
}
