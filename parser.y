%{
	#include <stdio.h>
    #include <ctype.h>
    void yyerror(char *s);
    extern char *yytext;
    extern int yylex();
    extern int yyparse();
    extern int scope;
    struct entry {
                int token_type;
                char *data_type;
                char* token_name;
                char* scope;
                int valid;
                struct entry *next;
             }*node;

    struct entry* head = NULL;
    FILE *f1;
    
    int error_flag = 0;
    int f_arg = 0;
    char* f_name;
    extern char* text;
    extern int numtext;
    int main_flag=0;
    int array = 0;
    char st[1000][10];
    int top=0;
    int i=0;
    char temp[2]="t";
    int return_flag=0;
    
    int label[200];
    int iflabel[200];
    int iftop=0;
    int ifnum = 0;
    int lnum=0;
    int ltop=0;
    char type[10];
%}

%union{
  int   int_val;
  char*	op_val;
  float real_val;
}

%token INTEGER DOUBLE CHARACTER IDENTIFIER STRINGLITERAL FLOAT CHAR FUNCTION ARRAY
%token RETURN VOID INT MAIN IF FOR ELSE BREAK CONTINUE
%token ADD_OP SUB_OP MUL_OP DIV_OP GE_OP EE_OP NE_OP LE_OP L_OP G_OP NOT_OP ASSIGN_OP

%left ADD_OP SUB_OP MUL_OP DIV_OP GE_OP EE_OP NE_OP LE_OP L_OP G_OP NOT_OP
%right ASSIGN_OP
%nonassoc "then"
%nonassoc ELSE

%%

function
    : INT IDENTIFIER {set_f_name();STMT_DECLARE_FUNC(1); set_func_label();} '(' ')' '{' statementlist RETURN {return_flag =1;}  arg_expression {return_flag = 0;} ';' '}' {set_valid();} mainfunction 
    | INT IDENTIFIER {set_f_name();STMT_DECLARE_FUNC(1); set_func_label();} '(' INT {setType();} IDENTIFIER {f_arg = 1;STMT_DECLARE_ID(); set_data_type();}')' '{' statementlist RETURN {return_flag =1;}  arg_expression {return_flag = 0;} ';' '}' {set_valid();} mainfunction 
    | mainfunction 
    ;

mainfunction
	: INT MAIN {set_f_name(); STMT_DECLARE_FUNC(1); set_mainflag();set_func_label();} '(' ')' '{' statementlist RETURN {return_flag =1;}  arg_expression {return_flag = 0;} ';' '}' {set_valid(0);}
	| VOID MAIN {set_f_name(); STMT_DECLARE_FUNC(0); set_mainflag();set_func_label();} '(' ')' '{' statementlist RETURN {fprintf(f1,"\tEND\n");}';' '}' {set_valid(0);}
	; 

statementlist
    : statement
    | statement statementlist
    ;

statement
	: expressionstatement ';'
    | forstatement 
    | conditionalstatement 
	| compoundstatement 
	| declerationstatement
	| jumpstatement 
	| functioncallstatement
	| assignmentstatement
	| ';'
	;

assignmentstatement
    : IDENTIFIER {check(); push_text();} ASSIGN_OP {push();} float_expression {codegen_assign();}
    | arrayindex ASSIGN_OP {push();} float_expression {codegen_assign1();}  
    ;

declerationstub
	: IDENTIFIER {STMT_DECLARE_ID();set_data_type();}
	| IDENTIFIER {set_arr(); STMT_DECLARE_ID();set_data_type();} '[' arg_expression ']'
	| IDENTIFIER {STMT_DECLARE_ID();push_text();set_data_type();} ASSIGN_OP {push();} float_expression {codegen_assign();} 
	;
        
c_declerationstub
	: IDENTIFIER {STMT_DECLARE_ID();set_data_type();}
	| IDENTIFIER {set_arr(); STMT_DECLARE_ID();set_data_type();} '[' arg_expression ']'
	| IDENTIFIER {STMT_DECLARE_ID();push_text();set_data_type();} ASSIGN_OP {push();} CHARACTER {codegen_assign();}
	| IDENTIFIER {set_arr(); STMT_DECLARE_ID();push_text();set_data_type();} '[' arg_expression ']' ASSIGN_OP {push();} STRINGLITERAL {codegen_assign();}
	;

declerationstatement
	: INT {setType();} declerationstub declerationlist ';'
	| FLOAT {setType();} declerationstub declerationlist ';'
	| CHAR {setType();} c_declerationstub c_declerationlist ';'
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
    : IF '(' float_expression ')'  {if_label1();} statement ELSESTMT 
	;
	
ELSESTMT
    : ELSE {if_label2();} statement {if_label3();}
	| {if_label3();}
	;

functioncallstatement
    : IDENTIFIER {check_func(); goto_func_label(); /*add_func_label();*/} '(' ')' ';' {check_f_arg(0);}
    | IDENTIFIER {check_func(); goto_func_label(); /*add_func_label();*/} '(' arg_expression ')' ';' {check_f_arg(1);}
    ;

jumpstatement
    : BREAK ';' {stmt_break();} 
    | CONTINUE ';' {stmt_continue();} 
    ;

forstatement
	: FOR '(' optionalassignstatement ';' {for_label1();} optionaltestexpressionstatement ';' {for_label2();} optionalassignstatement {post_update();} ')' {for_label3();} statement {for_label4();}
	;
 
optionaltestexpressionstatement
    : {strcpy(st[++top],"true");}
    | float_expression
	| float_expression ',' float_expression
	;

optionalassignstatement
    :
    | optional_assign_expression 
    | optional_assign_expression ',' optionalassignstatement
    ;
    
optional_assign_expression
    :
    | IDENTIFIER {check(); push_text();} ASSIGN_OP {push();} float_expression {codegen_assign();}        
	| arrayindex ASSIGN_OP {push();} float_expression {codegen_assign1();} 
	;

expressionstatement
	: float_expression                         
	| float_expression ',' expressionstatement
	;  

arg_expression
    : INTEGER {push();check_return_num();}  
    | IDENTIFIER {check(); push_text();check_return_id();}
    | arg_expr
    ;

arg_expr
    : IDENTIFIER {check();push_text();}
    | INTEGER { push();}
    | functioncallstatement                                  
    | '(' arg_expr ')' {check_return_arg();}                               	
	| arg_expr ADD_OP {push();} arg_expr {codegen_algebric();}     
	| arg_expr SUB_OP {push();} arg_expr {codegen_algebric();}      
	| arg_expr MUL_OP {push();} arg_expr {codegen_algebric();}          
	| arg_expr DIV_OP {push();} arg_expr {codegen_algebric();}    
	;

float_expression
    : DOUBLE {push();}                                      
    | expression  
    | functioncallstatement                                  
    | '(' float_expression ')'                                  	
	| float_expression ADD_OP {push();} float_expression {codegen_algebric();}     
	| float_expression SUB_OP {push();} float_expression {codegen_algebric();}      
	| float_expression MUL_OP {push();} float_expression {codegen_algebric();}          
	| float_expression DIV_OP {push();} float_expression {codegen_algebric();}      
	| float_expression G_OP {push();} float_expression {codegen_logical();}             
	| float_expression L_OP {push();} float_expression {codegen_logical();}
	| float_expression GE_OP {push();} float_expression {codegen_logical();}
	| float_expression LE_OP {push();} float_expression {codegen_logical();}
	| float_expression EE_OP {push();} float_expression {codegen_logical();}
	| float_expression NE_OP {push();} float_expression {codegen_logical();}
	| NOT_OP {push();} float_expression {codegen_logicalnot();}
    ;
   
expression
	: INTEGER {push();}                                        
	| IDENTIFIER {check(); push_text();}                                  
    | arrayindex 
	;

arrayindex
	: IDENTIFIER  {check_arr(); push_text();} '[' arg_expression ']' 
	;

%%

void yyerror(char *s) {
    error_flag = 1;
    fprintf(stderr, "%s %s \n", s, yytext);
}

//symboltable
int search_symbol(struct entry** head, char* token_name,char *scope)
{
    int flag=0;
    struct entry* temp = *head;
    while(temp!=NULL)
    {
        if((strcmp(temp->token_name,token_name)==0) && (strcmp(temp->scope,scope)==0) &&(temp->valid == 1))
        {
            flag=1;
            break;
        }
        temp=temp->next;
    }
    return flag;
}

struct entry* insert_node(struct entry** head,int ntoken, char* yytext,int scope,char *type) {
    node = (struct entry*)malloc(sizeof(struct entry));
    node->token_type = ntoken;
    node->scope = malloc(8);
    if(scope==-1)
        node->scope="NA";
     else if(scope==0)
        node->scope="global";
     else {
        sprintf(node->scope,"local%d",scope);
    }
    node->data_type=malloc(5);
    strcpy(node->data_type,type);
    node->token_name = malloc(strlen(yytext)+1);
    strcpy(node->token_name, yytext);
    node->valid = 1;
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
      printf("ERROR could not open file!");
      exit(1);
     }
    fprintf(fptr,"\nSYMBOL TABLE:\n_______________________________________\n\n|TOKEN TYPE |TOKEN NAME |DATA TYPE |SCOPE|\n_______________________________________\n");
    struct entry* temp = head;
    while(temp!=NULL)	
    {
        switch(temp->token_type) {
            
            case IDENTIFIER: fprintf(fptr,"%s\t\t%s\t\t\t%s\t\t%s\n","IDENTIFIER",temp->token_name,temp->data_type,temp->scope);
                             break;
            case ARRAY: fprintf(fptr,"%s\t\t\t%s\t\t\t%s\t\t%s\n","ARRAY",temp->token_name,temp->data_type,temp->scope);
                             break;

            case MAIN:
            case FUNCTION: fprintf(fptr,"%s\t\t%s\t\t%s\t\t%s\n","FUNCTION",temp->token_name,temp->data_type,temp->scope);
                       break;
          
        }   
        
        temp=temp->next;
    }
        fclose(fptr);

}

//Semantic analyser
void set_valid()
{
    struct entry* temp = head;
    while(temp != NULL)
    {
        if(temp->valid == 1)
        {
            temp->valid = 0;
        }
        temp=temp->next;
    }
}
void set_f_name() {
    f_name = malloc(sizeof(text)+1);
    strcpy(f_name,text);
}

void check_f_arg(int arg) {
    if(f_arg != arg) {
        printf("ERROR: Number of parameters mismatch for function %s \n",f_name);
        error_flag = 1;
        exit(1);
    }
}

void push()
{
  	strcpy(st[++top],yytext);
}

void push_text()
{
  	strcpy(st[++top],text);  
}

void codegen_logical()
{
 	sprintf(temp,"$t%d",i);
  	fprintf(f1,"\t%s\t=\t%s\t%s\t%s\n",temp,st[top-2],st[top-1],st[top]);
  	top-=2;
 	strcpy(st[top],temp);
 	i++;
}

void codegen_logicalnot()
{
 	sprintf(temp,"$t%d",i);
  	fprintf(f1,"\t%s\t=\t%s\t%s\n",temp,st[top-1],st[top]);
  	top-=1;
 	strcpy(st[top],temp);
 	i++;
}

void codegen_algebric()
{
 	sprintf(temp,"$t%d",i); // converts temp to read format
  	fprintf(f1,"\t%s\t=\t%s\t%s\t%s\n",temp,st[top-2],st[top-1],st[top]);
  	top-=2;
 	strcpy(st[top],temp);
 	i++;
}

void codegen_assign1()
{
 	fprintf(f1,"\t%s[%s]\t=\t%s\n",st[top-3],st[top-2],st[top]);
 	top-=4;
}

void codegen_assign()
{
 	fprintf(f1,"\t%s\t=\t%s\n",st[top-2],st[top]);
 	top-=3;
}
 
void if_label1()
{
 	ifnum++;
 	fprintf(f1,"\tif( not %s)",st[top]);
 	fprintf(f1,"\tgoto $I%d\n",ifnum);
 	iflabel[++iftop]=ifnum;
}

void if_label2()
{
	int x;
	ifnum++;
	x=iflabel[iftop--]; 
	fprintf(f1,"\t\tgoto $I%d\n",ifnum);
	fprintf(f1,"$I%d: \n",x); 
	iflabel[++iftop]=ifnum;
}

void if_label3()
{
    printf("iftop = %d\n",iftop);
	int y;
	y=iflabel[iftop--];
	fprintf(f1,"$I%d: \n",y);
}

void for_label1()
{
    lnum++;
 	label[++ltop]=lnum; //test_expr
 	label[++ltop]=++lnum; //update_expr
 	label[++ltop]=++lnum; // start_of_for_body
 	label[++ltop]=++lnum; //line_after_for
 	fprintf(f1,"$L%d : \n",label[ltop-3]);
 	
}

void for_label2()
{
    fprintf(f1,"\tif(not %s) goto $L%d\n",st[top],label[ltop]);
    fprintf(f1,"\telse goto $L%d\n",label[ltop-1]);
    fprintf(f1,"$L%d : \n",label[ltop-2]); 
}

void for_label3()
{
   fprintf(f1,"$L%d : \n",label[ltop-1]); 
}

void post_update()
{
    fprintf(f1,"\tgoto $L%d\n",label[ltop-3]);
}

void for_label4()
{
   fprintf(f1,"\tgoto $L%d\n",label[ltop-2]);
   fprintf(f1,"$L%d : \n",label[ltop]); 
   ltop-=4;
}

void stmt_break()
{
    int y;
	y=label[ltop];
	fprintf(f1,"\tgoto $L%d: \n",y);
}

void stmt_continue()
{ 
    int y;
	y=label[ltop-2];
	fprintf(f1,"\tgoto $L%d: \n",y);
}

void stmt_return(int args)
{
    if(args)
        fprintf(f1,"\treturn value = %s\n",text);
    fprintf(f1,"\tgoto $Lcontinue\n");
            
}

void set_data_type()
{
    struct entry *temp = head;
    while(temp!=NULL)
    {
        if(strcmp(text,temp->token_name)==0)
        {
            strcpy(temp->data_type,type);
        }
        temp=temp->next;
    }
}

void set_func_label()
{
    fprintf(f1,"$L%s :\n",text);
}

void goto_func_label()
{
    fprintf(f1,"\tgoto $L%s \n",text);
    fprintf(f1,"$Lcontinue :\n");
}

void check_arr()
{
    int flag=0;
    struct entry* temp = head;
    while(temp!=NULL)
    {
        if(strcmp(temp->token_name,text)==0 && temp->token_type==ARRAY && temp->valid == 1)
        {
            flag=1;
            break;
        }
        temp=temp->next;
    }
    if(flag==0) {
         printf("ERROR! array %s not declared\n", text);
         error_flag = 1;
         exit(1);
    } 
}

void check_func()
{
    int flag=0;
    struct entry* temp = head;
    while(temp!=NULL)
    {
        if(strcmp(temp->token_name,text)==0 && temp->token_type==FUNCTION)
        {
            flag=1;
            break;
        }
        temp=temp->next;
    }
    if(flag==0) {
         printf("ERROR! function %s not declared\n", yytext);
         error_flag = 1;
         exit(1);
    }
}

void check()
{
    int flag=0;
    struct entry* temp = head;
    while(temp!=NULL)
    {
        char *tscope;
        tscope = (char *)malloc(8);
        if(scope == -1)
            tscope="NA";
        else if(scope == 0)
            tscope="global";
        else {
            sprintf(tscope,"local%d",scope);
        }
        if((strcmp(temp->token_name,text)==0) && (strcmp(temp->scope,tscope)<=0) && (temp->valid == 1))
        {
            flag=1;
            break;
        }
        temp=temp->next;
    }
    if(flag==0) {
         printf("ERROR! variable %s not declared\n", text);
         error_flag = 1;
         exit(1);
    }
}

void check_return_num()
{
    if(return_flag)
        fprintf(f1,"\treturn %d\n",numtext);
}
void check_return_id()
{
    if(return_flag)
        fprintf(f1,"\treturn %s\n",text);
}
void check_return_arg()
{
    if(return_flag)
    {
        fprintf(f1,"\treturn %s\n",st[top--]);
    }
}
void set_mainflag()
{
    if(main_flag==0)
        main_flag=1;
    else
    {
        printf("ERROR: Two main functions not allowed\n");
        error_flag = 1;
        exit(1);
    }    
}

void setType()
{
	strcpy(type,yytext);
}

void set_arr()
{
    array = 1;
}

void STMT_DECLARE_ID()
{
    int flag=0;
    struct entry* temp = head;
    while(temp!=NULL)
    {
        char *tscope;
        tscope = (char *)malloc(8);
        if(scope==-1)
            tscope="NA";
        else if(scope==0)
            tscope="global";
        else {
            sprintf(tscope,"local%d",scope);
        }
        if((strcmp(temp->token_name,text)==0) && (strcmp(temp->scope,tscope) == 0) && (temp->valid == 1))
        {
            flag=1;
            break;
        }
        temp=temp->next;
    }
    if(flag==1) {
         printf("ERROR! variable %s redeclared\n",text);
         printf("present : %d old : %s\n",scope,temp->scope);
         error_flag = 1;
         exit(1);
    }
    if(array)
    {
        head = insert_node(&head,ARRAY,text,scope,type);
    }
    else
        head = insert_node(&head,IDENTIFIER,text,scope,type);
    array = 0;
}

void STMT_DECLARE_FUNC(int type)
{
    int flag=0;
    struct entry* temp = head;
    while(temp!=NULL)
    {
        if(strcmp(temp->token_name,text)==0)
        {
            flag=1;
            break;
        }
        temp=temp->next;
    }
    if(flag==1) {
         printf("ERROR! function %s redeclared\n",text);
         exit(1);;
    }
    if(type)
        head = insert_node(&head,FUNCTION,text,0,"int");
    else
        head = insert_node(&head,FUNCTION,text,0,"void");
}

int main(int argc,char** argv)
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
    f1=fopen("icg.txt","w");
    if (!f1)
    {
        fprintf(stderr, "Could not open semantic_analysis.txt\n");
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
