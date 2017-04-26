/*eg1.y -- demo usage for lemon.

doc:
 lemon is from sqlite-src/tool/.

test:
 ../lemon -l eg1.y 
 gcc -g -O0 eg1.c && ./a.out
 
*/

%include {
#include <string.h>
#include <stdlib.h>
#include <assert.h>
	
#include "eg1.h"
		
//disable error recovery in PDA
#define YYNOERRORRECOVERY 1
	
typedef struct{
	int res;
	int p1;
	int p2;
	int rc;
}MyStruct;
	
}//end include
	

program ::=  expr(A). {  pMy->res = A; }
expr(A) ::= expr(B) PLUS expr(C).	{  A = B + C ; }
expr(A) ::= expr(B) TIMES expr(C).{  A = B * C ; }
expr ::= INTEGER.

//precedence
%left PLUS MINUS .
%left TIMES .

%type expr {int}
%token_type {int}
	
%token_prefix TK_
//parse entry
%name MyParse
%extra_argument {MyStruct *pMy}
	
%syntax_error {
	pMy->rc = -1;
}

%code {

int main(int ac, char **av)
{
	MyParseTrace(stderr, "dbg");
	void *p = MyParseAlloc(malloc);

	MyStruct my = {0};

	//getToken for "3+4*5+6"
	MyParse(p,TK_INTEGER,3, &my);
	MyParse(p,TK_PLUS,0, &my);
	MyParse(p,TK_INTEGER,4, &my);
	MyParse(p,TK_TIMES,0, &my);
	MyParse(p,TK_INTEGER,5, &my);
	MyParse(p,TK_PLUS,0, &my);
	MyParse(p,TK_INTEGER,6, &my);

	MyParse(p,0,0, &my);

	MyParseFree(p, free);

	if(my.rc == 0){
		printf("result = %d\n", my.res);
	}else{
		printf("err %d\n", my.rc);
	}

	return 0;
}

}//end of code
	
