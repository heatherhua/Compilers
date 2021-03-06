/* File:  scanner.l
 * ----------------
 * Lex input file to generate the scanner for the compiler.
 */

%{

/* The text within this first region delimited by %{ and %} is assumed to
 * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
 * of the definitions of the yylex() function. Add other header file inclusions
 * or C++ variable declarations/prototypes that are needed by your code here.
 */

#include <string.h>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"

/* Global variable: yylval
 * -----------------------
 * This global variable is how we get attribute information about the token
 * just scanned to the client. The scanner sets the global variable
 * appropriately and since it's global the client can just read it.  In the
 * future, this variable will be declared for us in the y.tab.c file
 * produced by Yacc, but for now, we declare it manually.
 */
YYSTYPE yylval;  // manually declared for pp1, later Yacc provides

/* Global variable: yylloc
 * -----------------------
 * This global variable is how we get position information about the token
 * just scanned to the client. (Operates similarly to yylval above)
 */
struct yyltype yylloc; // manually dclared for pp1, later Yacc provides

/* Macro: YY_USER_ACTION 
 * ---------------------
 * This flex built-in macro can be defined to provide an action which is
 * always executed prior to any matched rule's action. Basically, it is
 * a way of having a piece of code common to all actions factored out to
 * this routine.  We already defined it for you and left the empty
 * function DoBeforeEachAction ready for your use as needed. It will
 * be called once for each pattern scanned from the file, before
 * executing its action.
 */
static void DoBeforeEachAction(); 
#define YY_USER_ACTION DoBeforeEachAction();

%}

 /* The section before the first %% is the Definitions section of the lex
  * input file. Here is where you set options for the scanner, define lex
  * states, and can set up definitions to give names to regular expressions
  * as a simple substitution mechanism that allows for more readable
  * entries in the Rules section later. 
  */
/*
 Reserved section:

"extends"	{ return T_Extends; }
"this"		{ return T_This; }
"implements" 	{ return T_Implements; }
"interface" 	{ return T_Interface; }
"new"		{ return T_New; }
"class"		{ return T_Class; }
"NULL"		{ return T_Null; }

*/
%x comment
%%             /* BEGIN RULES SECTION */

 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 
"/*"         BEGIN(comment);

<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by '/'s */
<comment>\n             ++yylloc.first_line;
<comment>"*"+"/"        BEGIN(INITIAL); 



[ ]		{ yylloc.last_column++; }
[\t]		{ yylloc.last_column += 8;}
[\n] 		{ yylloc.first_line++; yylloc.first_column = 0; yylloc.last_column = 0;}
[\r] 		{ }
"void"		{ yylloc.last_column += yyleng;  return T_Void; }
"int"		{ yylloc.last_column += yyleng;  return T_Int; }
"float"		{ yylloc.last_column += yyleng;  return T_Float; }
"bool"		{ yylloc.last_column += yyleng;  return T_Bool; }
"string"	{ yylloc.last_column += yyleng;  return T_String; }
"\[\]"		{ yylloc.last_column += yyleng;  return T_Dims; }
"<="		{ yylloc.last_column += yyleng;  return T_LessEqual; }
">="		{ yylloc.last_column += yyleng;  return T_GreaterEqual; }
"=="		{ yylloc.last_column += yyleng;  return T_Equal; }
"!="		{ yylloc.last_column += yyleng;  return T_NotEqual; }
"++"		{ yylloc.last_column += yyleng;  return T_Inc; }
"--"		{ yylloc.last_column += yyleng;  return T_Dec; }
"="             { yylloc.last_column += yyleng;  return '=';}
";"		{ yylloc.last_column += yyleng;  return ';';}
"+"		{ yylloc.last_column += yyleng;  return '+';}
"-"		{ yylloc.last_column += yyleng;  return '-';}
"("		{ yylloc.last_column += yyleng;  return '('; }
")"		{ yylloc.last_column += yyleng;  return ')';}
"]"		{ yylloc.last_column += yyleng;  return ']';}
"["		{ yylloc.last_column += yyleng;  return '[';}
"*"		{ yylloc.last_column += yyleng;  return '*';}
"/"		{ yylloc.last_column += yyleng;  return '/';}
"%"		{ yylloc.last_column += yyleng;  return '%';}
"<"		{ yylloc.last_column += yyleng;  return '<';}
">"		{ yylloc.last_column += yyleng;  return '>';}
"!"		{ yylloc.last_column += yyleng;  return '!';}
"."		{ yylloc.last_column += yyleng;  return '.';}
","		{ yylloc.last_column += yyleng;  return ',';}
"{"		{ yylloc.last_column += yyleng;  return '{';}
"}"		{ yylloc.last_column += yyleng;  return '}';}
"&&"		{ yylloc.last_column += yyleng;  return T_And; }
"||"		{ yylloc.last_column += yyleng;  return T_Or; }
"while"		{ yylloc.last_column += yyleng;  return T_While; }
"for"		{ yylloc.last_column += yyleng;  return T_For; }
"if"		{ yylloc.last_column += yyleng;  return T_If; }
"else"		{ yylloc.last_column += yyleng;  return T_Else; }
"return"	{ yylloc.last_column += yyleng;  return T_Return; }
"break"		{ yylloc.last_column += yyleng; return T_Break; }
"true"		{ yylloc.last_column += yyleng; yylval.boolConstant = true; return T_BoolConstant;}
"false"		{ yylloc.last_column += yyleng; yylval.boolConstant = false; return T_BoolConstant;}


"\"*\""		{ return T_StringConstant; }

((-?)[0-9][0-9]*f) |
((-?)[0-9][0-9]*\.[0-9]*f) |
((-?)[0-9]*\.[0-9][0-9]*(f?)) |	
((-?)[0-9][0-9]*\.)	{ 
						yylloc.last_column += yyleng; 
						yylval.floatConstant = strtod(yytext, NULL); 
						return T_FloatConstant; 
					}

-?([0-9]{1,9}|1[0-9]{9}|2(0[0-9]{8}|1([0-3][0-9]{7}|4([0-6][0-9]{6}|7([0-3][0-9]{5}|4([0-7][0-9]{4}|8([0-2][0-9]{3}|3([0-5][0-9]{2}|6([0-3][0-9]|4[0-7])))))))))|^-2147483648 { yylloc.last_column += yyleng; yylval.integerConstant = strtod(yytext, NULL); return T_IntConstant; }

"do"		{ yylloc.last_column += yyleng;  return T_Do; }
"switch"	{ yylloc.last_column += yyleng;  return T_Switch; }
"case"		{ yylloc.last_column += yyleng;  return T_Case; }
"in"		{ yylloc.last_column += yyleng;  return T_In; }
"out"		{ yylloc.last_column += yyleng;  return T_Out;}
"inout"         { yylloc.last_column += yyleng;  return T_Inout;}
"default"	{ yylloc.last_column += yyleng;  return T_Default; }
"struct"	{ yylloc.last_column += yyleng;  return T_Struct; }
"uint"		{ yylloc.last_column += yyleng;  return T_Uint; }
"uniform"	{ yylloc.last_column += yyleng;  return T_Uniform; }
"const"		{ yylloc.last_column += yyleng;  return T_Const;}
"continue"	{ yylloc.last_column += yyleng;  return T_Continue;}
"layout"        { yylloc.last_column += yyleng;  return T_Layout; }
"vec2"	{ yylloc.last_column += yyleng;  return T_Vec2;}
"vec3"	{ yylloc.last_column += yyleng;  return T_Vec3;}
"vec4"	{ yylloc.last_column += yyleng;  return T_Vec4;}
"mat2"	{ yylloc.last_column += yyleng;  return T_Mat2;}
"mat3"	{ yylloc.last_column += yyleng;  return T_Mat3;}
"mat4"	{ yylloc.last_column += yyleng;  return T_Mat4;}
"ivec2"	{ yylloc.last_column += yyleng;  return T_Ivec2;}
"ivec3"	{ yylloc.last_column += yyleng;  return T_Ivec3;}
"ivec4"	{ yylloc.last_column += yyleng;  return T_Ivec4;}
"bvec2"	{ yylloc.last_column += yyleng;  return T_Bvec2;}
"bvec3"	{ yylloc.last_column += yyleng;  return T_Bvec3;}
"bvec4"	{ yylloc.last_column += yyleng;  return T_Bvec4;}
"uvec2"	{ yylloc.last_column += yyleng;  return T_Uvec2;}
"uvec3"	{ yylloc.last_column += yyleng;  return T_Uvec3;}
"uvec4"	{ yylloc.last_column += yyleng;  return T_Uvec4;}

[_a-zA-Z][a-zA-Z0-9]* |
[_][a-zA-Z0-9][_a-zA-Z0-9]* |
[a-zA-Z][_a-zA-Z0-9]*{1,31} 	{ 
									if(yyleng > 1023) {
										ReportError::LongIdentifier(&yylloc, yytext);
									} else {
										
										yylloc.last_column += yyleng;
										strncpy(yylval.identifier, yytext, MaxIdentLen); yylval.identifier[MaxIdentLen] = '\0'; 
										return T_Identifier;
									}
								}

%%
/* The closing %% above marks the end of the Rules section and the beginning
 * of the User Subroutines section. All text from here to the end of the
 * file is copied verbatim to the end of the generated lex.yy.c file.
 * This section is where you put definitions of helper functions.
 */


/* Function: InitScanner
 * ---------------------
 * This function will be called before any calls to yylex().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yy_flex_debug that controls whether flex prints debugging information
 * about each token and what rule was matched. If set to false, no information
 * is printed. Setting it to true will give you a running trail that might
 * be helpful when debugging your scanner. Please be sure the variable is
 * set to false when submitting your final version.
 */
void InitScanner()
{
    PrintDebug("lex", "Initializing scanner");
    yy_flex_debug = false;

    yylloc.first_line = 1;
}


/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
	yylloc.first_column = yylloc.last_column + 1;	
}
