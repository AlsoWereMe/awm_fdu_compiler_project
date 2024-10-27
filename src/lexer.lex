%{
#include <stdio.h>
#include <string.h>
#include "TeaplAst.h"
#include "y.tab.hpp"
extern int line, col;
int c;
int calc(const char *s, int len);
%}

// TODO:
// your lexer
nline [\r\n]
blank [\t ]+
num  0|[1-9][0-9]*
letter [a-zA-Z_]
id  {letter}({num}|{letter})*

%s SINGLE_COMMENT MULTI_COMMENT

%%
<INITIAL>{
/* non-token logic begin */
    "//" { BEGIN SINGLE_COMMENT; }
    "/*" { BEGIN MULTI_COMMENT; }
    {blank} { col += yyleng; }
    {nline} { line += 1; col = 1; }
 /* non-token logic end */

/* token logic begin */
    /* A_pos A_Pos(int, int) */
    /* arithmetic */
    "+" { yylval.pos = A_Pos(line, col); col += yyleng; return ADD; }
    "-" { yylval.pos = A_Pos(line, col); col += yyleng; return SUB; }
    "*" { yylval.pos = A_Pos(line, col); col += yyleng; return MUL; }
    "/" { yylval.pos = A_Pos(line, col); col += yyleng; return DIV; }
    /* compare */
    ">"  { yylval.pos = A_Pos(line, col); col += yyleng; return GT; }
    "<"  { yylval.pos = A_Pos(line, col); col += yyleng; return LT; }
    ">=" { yylval.pos = A_Pos(line, col); col += yyleng; return GE; }
    "<=" { yylval.pos = A_Pos(line, col); col += yyleng; return LE; }
    "==" { yylval.pos = A_Pos(line, col); col += yyleng; return EQ; }
    "!=" { yylval.pos = A_Pos(line, col); col += yyleng; return NE; }
    /* boolean */
    "!"  { yylval.pos = A_Pos(line, col); col += yyleng; return NOT; }
    "&&" { yylval.pos = A_Pos(line, col); col += yyleng; return AND; }
    "||" { yylval.pos = A_Pos(line, col); col += yyleng; return OR; }
    /* bracket */
    "(" { yylval.pos = A_Pos(line, col); col += yyleng; return LPARENT; }
    ")" { yylval.pos = A_Pos(line, col); col += yyleng; return RPARENT; }
    "[" { yylval.pos = A_Pos(line, col); col += yyleng; return LBRACKETS; }
    "]" { yylval.pos = A_Pos(line, col); col += yyleng; return RBRACKETS; }
    "{" { yylval.pos = A_Pos(line, col); col += yyleng; return LBRACES; }
    "}" { yylval.pos = A_Pos(line, col); col += yyleng; return RBRACES; }
    /* keyword */
    "fn"       { yylval.pos = A_Pos(line, col); col += yyleng; return FN; }
    "let"      { yylval.pos = A_Pos(line, col); col += yyleng; return LET; }
    "struct"   { yylval.pos = A_Pos(line, col); col += yyleng; return STRUCT; }
    "continue" { yylval.pos = A_Pos(line, col); col += yyleng; return CONTINUE; }
    "break"    { yylval.pos = A_Pos(line, col); col += yyleng; return BREAK; }
    "ret"      { yylval.pos = A_Pos(line, col); col += yyleng; return RETURN; }
    "if"       { yylval.pos = A_Pos(line, col); col += yyleng; return IF; }
    "else"     { yylval.pos = A_Pos(line, col); col += yyleng; return ELSE; }
    "while"    { yylval.pos = A_Pos(line, col); col += yyleng; return WHILE; }
    /* A_type A_NativeType(A_pos pos, A_nativeType ntype) */
    "int" { yylval.type = A_NativeType(A_Pos(line, col), A_intTypeKind); col += yyleng; return INT; }
    /* member */
    "->" { yylval.pos = A_Pos(line, col); col += yyleng; return ARROW; }
    "\." { yylval.pos = A_Pos(line, col); col += yyleng; return POINT; }
    /* special */
    "=" { yylval.pos = A_Pos(line, col); col += yyleng; return ASSIGN; }
    "," { yylval.pos = A_Pos(line, col); col += yyleng; return COMMA; }
    ":" { yylval.pos = A_Pos(line, col); col += yyleng; return COLON; }
    ";" { yylval.pos = A_Pos(line, col); col += yyleng; return SEMICOLON; }
    /* A_tokenNum A_TokenNum(A_Pos, int) */
    {num} {
        yylval.tokenNum = A_TokenNum(A_Pos(line, col), calc(yytext, yyleng));
        col += yyleng;
        return NUM;
    }
    /* A_tokenId A_TokenId(A_Pos, char*) */
    {id} {
        yylval.tokenId = A_TokenId(A_Pos(line, col), strdup(yytext));
        col += yyleng;
        return ID;
    }
/* token logic end */

    /* error */
    . { printf("Illegal input \"%c\"\n", yytext[0]); }
}

<SINGLE_COMMENT>{
    {nline} { BEGIN INITIAL; line += 1; col = 1; }
    . {}
}

<MULTI_COMMENT>{
    {nline} { BEGIN INITIAL; line += 1; col = 1; }
    "*/" { BEGIN INITIAL; col += yyleng; }
    . {}
}
%%

// This function takes a string of digits and its length as input, and returns the integer value of the string.
int calc(const char *s, int len) {
    int ret = 0;
    for(int i = 0; i < len; i++)
        ret = ret * 10 + (s[i] - '0');
    return ret;
}