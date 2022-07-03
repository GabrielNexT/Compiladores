%{
#include <bits/stdc++.h>

using namespace std;

struct Attributes {
    vector<string> c;
};

// Tipos de variáveis
enum Types {
    VAR,
    LET,
    CONST
};

// Meta dado de variável, as colunas poderiam ser inseridas aqui tbm.
struct VariablesMetadata {
    int line;
    Types type;
};

#define YYSTYPE Attributes

map<vector<string>, VariablesMetadata> vars;
// Linha atual do arquivo
int currentLine = 1;
// Variável usada para gerar labels únicos
int labelCount = 0;

void insertVar(vector<string> var);
void insertVar(vector<string> var, Types type);
void checkVar(vector<string> var);

// Operadores e funções para facilitar minha vida
vector<string> operator+(vector<string> a, string b);
vector<string> operator+(vector<string> a, vector<string> b);
vector<string> concat(vector<string> a, vector<string> b);
vector<string> solveAdress(vector<string> entrada);
string genLabel(string prefix);
void print(vector<string> code);

int yylex();
int yyparse();
void yyerror(const char *);
%}

%token OR_T DV_T DL_T DC_T FOR_T WHILE_T IF_T ELSE_T ELSEIF_T NUM_T ID_T STRING_T PE_T PP_T

// Sentença inicial da gramática
%start S

%right '=' PP_T
%nonassoc '>' '<' OR_T
%left '+' '-'
%left '*' '/'


%%
S: CMDs { print(solveAdress($1.c));}
;

CMD: E V ';' {$$.c = $1.c + "^" + $2.c;}
|    E V     {$$.c = $1.c + $2.c;}
|    FOR                    
|    FOR ';'               
|    IF                    
|    IF  ';'                  
|    WHILE                 
|    WHILE ';'            
;

// Bloco de código
CMDs: CMD CMDs {$$.c = $1.c + $2.c;}
|              {$$.c = vector<string>();}
;

// Definição de variável
DEFV: DV_T LVALUE 	      {$$.c = $2.c + "&"; insertVar($2.c);} 
|     DL_T LVALUE 	      {$$.c = $2.c + "&"; insertVar($2.c, LET);} 
|     DC_T LVALUE 	      {$$.c = $2.c + "&"; insertVar($2.c, CONST);} 
|     DV_T LVALUE '=' E   {$$.c = $2.c + "&" + $2.c + $4.c + "=";  insertVar($2.c);}
|     DL_T LVALUE '=' E   {$$.c = $2.c + "&" + $2.c + $4.c + "=";  insertVar($2.c, LET);}
|     DC_T LVALUE '=' E   {$$.c = $2.c + "&" + $2.c + $4.c + "=";  insertVar($2.c, CONST);}
;

// Definição de objeto
DEFO: '{' '}' {$$.c = vector<string>() + "{}";}
; 

// Definição de array
DEFA: '[' ']' {$$.c = vector<string>() + "[]";}
;

// Array preenchido
AP: '[' E ']'AP       {$$.c = $2.c + "[@]" + $4.c;}
|   '[' E ']'         {$$.c = $2.c;}
;

// Atribuição
ATT: LVALUE '=' E 	      {$$.c = $1.c + $3.c + "="; checkVar($1.c);}
|    LVALUEPROP '=' E 	  {$$.c = $1.c + $3.c + "[=]";}
|    LVALUEPROP PE_T E 	  {$$.c = $1.c + $1.c + "[@]" + $3.c  + "+" + "[=]";}
|    LVALUEPROP PP_T E 	  {$$.c = $1.c + $3.c + "[=]";}
|    LVALUE PE_T E 	      {$$.c = $1.c + $1.c + "@" + $3.c + "+="; checkVar($1.c);}
|    LVALUE PP_T	      {$$.c =  $1.c + $1.c + "@" + "1" + "+" + "=" + "^" + $1.c + "@" + "1" + "-"; checkVar($1.c);}
|    LVALUE '=' ATT 	  {$$.c = $1.c + $3.c + "="; checkVar($1.c);}
|    DEFO
|    DEFA
;


// Valor da esquerda de variáveis, objetos e array.
LVALUEPROP: ID_T AP           {$$.c = $1.c + "@" + $2.c; checkVar($1.c);}
|           ID_T '.' ID_T     {$$.c = $1.c + "@" + $3.c; checkVar($1.c);}
|           ID_T '.' ID_T AP  {$$.c = $1.c + "@" + $3.c  + "[@]" + $4.c; checkVar($1.c);}
;

// Valor da esquerda padrão, só tem o ID mesmo.
LVALUE: ID_T {$$.c = $1.c;}
;

// Virgula
V: ',' ID_T '=' E V       {$$.c = $2.c + "&" + $2.c + $4.c + "=" + "^" + $5.c; insertVar($2.c);}
|  ',' ID_T V             {$$.c = $2.c + "&" + $3.c; insertVar($2.c);}
|                         {$$.c = {};}
;

// Condição do if
C: E '<' E         {$$.c = $1.c + $3.c + $2.c;}
|  E '>' E          {$$.c = $1.c + $3.c + $2.c;}
|  E OR_T E         {$$.c = $1.c + $3.c + $2.c;}
;

// If, o próprio.
IF: IF_T '(' C ')' CMD ELSEIF           { string if_ou_elseif = genLabel("if_ou_elseif");
                                        $$.c = $3.c + "!" + if_ou_elseif + "?" +  $5.c + (":" + if_ou_elseif) + $6.c;}
|   IF_T '(' C ')' '{' CMDs '}' ELSEIF    {string if_ou_elseif = genLabel("if_ou_elseif");
                                        $$.c = $3.c + "!" + if_ou_elseif + "?" +  $6.c + (":" + if_ou_elseif) + $8.c;}
|   IF_T '(' C ')' CMD ELSE               {string if_else = genLabel("if_else");
                                        $$.c = $3.c + "!" + if_else + "?" +  $5.c + (":" +  if_else);}
|   IF_T '(' C ')' '{' CMDs '}' ELSE      {string if_else = genLabel("if_else");
                                        $$.c = $3.c + "!" + if_else + "?" +  $6.c + (":" + if_else);}
|   IF_T '(' C ')' CMD                    {string if_end = genLabel("if_end");
                                        $$.c = $3.c + "!" + if_end + "?" +  $5.c + (":" + if_end);}
|   IF_T '(' C ')' '{' CMDs '}'           {string if_end = genLabel("if_end");
                                        $$.c = $3.c + "!" + if_end + "?" +  $6.c + (":" + if_end);}
;

// Else if, esse foi hard.
ELSEIF: ELSEIF_T '('C')' CMD ELSEIF      {string elseif = genLabel("elseif");
                                        $$.c = $3.c + "!" + elseif + "?" +  $5.c + (":" + elseif) + $6.c;}
|       ELSEIF_T '('C')''{'CMDs'}'ELSEIF {string elseif = genLabel("elseif");
                                        $$.c = $3.c + "!" + elseif + "?" +  $6.c + (":" + elseif) + $8.c;}
|       ELSEIF_T '('C')''{'CMDs'}'ELSE   {string elseif_else = genLabel("elseif_else");
                                        $$.c = $3.c + "!" + elseif_else + "?" + (":" + elseif_else) + $8.c +  $6.c;}
|       ELSEIF_T '('C')' CMD ELSE        {string elseif_else = genLabel("elseif_else");
                                        $$.c = $3.c + "!" + elseif_else + "?" + (":" + elseif_else) + $6.c +  $5.c;}                            
;


ELSE: ELSE_T '{' CMDs '}'  {$$.c = $3.c;}
|     ELSE_T CMD          {$$.c = $2.c;}   
;

WHILE: WHILE_T'('C')''{' CMDs '}'   {
    string whileCondInit = genLabel("whileCondInit");
    string whileCondEnd = genLabel("whileCondEnd");
    $$.c = vector<string>() + (":" + whileCondInit) + $3.c + "!" + whileCondEnd + "?" + $6.c + whileCondInit + "#" + (":" + whileCondEnd);
}
;

FOR: FOR_T'('CMD C ';' E')''{' CMDs '}' {
    string forCondInit = genLabel("forCondInit");
    string forCondEnd = genLabel("forCondEnd");
    $$.c = $3.c + (":" + forCondInit) + $4.c + "!" + forCondEnd + "?" + $9.c  + $6.c + "^" + forCondInit  + "#" + (":" + forCondEnd);
}
;


E: E '+' E             {$$.c = $1.c + $3.c + "+"; }
|  E '-' E             {$$.c = $1.c + $3.c + "-"; }
|  E '*' E             {$$.c = $1.c + $3.c + "*"; }
|  E '/' E             {$$.c = $1.c + $3.c + "/"; }
|  '-'E                {vector<string> t1 = {"0"}, t2 = {"-"}; $$.c = t1 + $2.c + t2; }
|  '('E')'             {$$.c = $2.c; }
|  NUM_T               {$$.c = $1.c; }
|  STRING_T            {$$.c = $1.c; }
|  LVALUE              {$$.c = $1.c + "@"; checkVar($1.c); }
|  LVALUEPROP          {$$.c = $1.c + "[@]"; }
|  ATT                 {$$.c = $1.c; }
|  DEFV
;

%%
#include "lex.yy.c"

vector<string> concat( vector<string> a, vector<string> b ) {
    a.insert(a.end(), b.begin(), b.end());
    return a;
}

vector<string> operator+( vector<string> a, vector<string> b ) {
    return concat(a, b);
}

vector<string> operator+( vector<string> a, string b ) {
    a.push_back(b);
    return a;
}

void insertVar(vector<string> var){
    insertVar(var, VAR);
}

void insertVar(vector<string> var, Types type = VAR){
    if(vars.count(var) && type == CONST) {
        printf("Erro: a variável '%s' já foi declarada na linha %d.\n", var.front().c_str(), vars[var].line);
        exit(1);
    } else if(vars.count(var) && type == LET) {
        printf("Erro: a variável '%s' já foi declarada na linha %d.\n", var.front().c_str(), vars[var].line);
        exit(1);
    }
    vars[var] = {currentLine, type};
}

void checkVar(vector<string> var){
    if(!vars.count(var)) {
        printf("Erro: a variável '%s' não foi declarada.\n", var.front().c_str());
        exit(1);
    }
}

vector<string> solveAdress( vector<string> input ) {
    map<string,int> label;
    vector<string> output;
    for( int i = 0; i < input.size(); i++ ) {
        if( input[i][0] == ':' ) label[input[i].substr(1)] = output.size();
        else output.push_back(input[i]);
    }
    for( int i = 0; i < output.size(); i++ ) {
        if(label.count( output[i] ) > 0) output[i] = to_string(label[output[i]]);
    }
    return output;
}

string genLabel( string prefix ) {
    return prefix + "_" + to_string(labelCount++) + ":";
}

void print(vector<string> code){
    for(int i = 0; i < code.size(); i++)
        cout << code[i] << endl;
    cout << "." << endl;
}

void yyerror( const char* msg ) {
    printf("Erro de sintaxe na linha %d próximo a: %s\n",  currentLine, yytext);
    exit(1);
}

int main( int argc, char* argv[] ) {
    yyparse();
    return 0;
}