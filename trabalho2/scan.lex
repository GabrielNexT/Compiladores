%{
#include <bits/stdc++.h>

using namespace std;

int token, lastToken;
string lexema;
int linha = 1, coluna_atual = 1, coluna_anterior = 0;

void casa(int);
int tk(int);
void A();
void E();
void E_linha();
void T();
void T_linha();
void F();
void F_linha();
void B();
void P();
void U();
void C();

bool isUniary = false;

enum { _ID = 256, _STRING, _NUM, _PRINT };

map<int,string> mp_tokens = {
  { _ID, "Nome do identificador" },
  { _STRING, "string" },
  { _NUM, "number" },
  { _PRINT, "print" },
};
%}

WS  [ \t\n]
D  [0-9]
L [A-Za-z]

_INT  [1-9]+[0-9]*|0
_FLOAT {D}+((\.?{D}+([eE]?[+-]?{D}*)?)|e[+-]?{D})

_STRING \"([^\"\n\\]|(\\\")|\"\"|"\\\\")+\"

_ID (_|\$|{L})+(_|{L}|{D})*

PRINT (print)

%%

" " { 
    coluna_anterior = coluna_atual++;
}

"\t" { 
    coluna_anterior = coluna_atual;
    coluna_atual += 2;
}

"\n" {
    linha++; 
    coluna_anterior = coluna_atual;
    coluna_atual = 1; 
}

{PRINT} {
    return tk(_PRINT);
}

{_FLOAT} {
    return tk(_NUM);
}

{_INT} {
    return tk(_NUM); 
}

{_ID} {
    return tk(_ID);
}

{_STRING} {
    return tk(_STRING);
}

. { 
    return yytext[0];
}

%%

void printError( string msg ) {
  cout << "ERROR!" << endl << "Linha: " << linha << " coluna: " << coluna_anterior << endl << msg << endl;
  exit( 1 );
}

int tk( int token ) {
  coluna_anterior = coluna_atual;
  coluna_atual += strlen( yytext ); 
  return token;
}

int next_token() {
    lastToken = token;
    return yylex();
}

void print_lexema(){
    cout << lexema + " ";
}

void B(){
    switch(token) {
        case _PRINT:
            casa(_PRINT);
            E();
            cout << "print # ";
            casa(';');
            cout << endl;
            B();
            break;
        case _ID:
            A();
            casa(';');
            cout << endl;
            B();
            break;
    }
}


void A() {
    casa(_ID);
    print_lexema();
    casa('=');
    E();
    cout << "= ";        
}

void E(){
    T();
    E_linha();
}

void E_linha(){
    switch(token) {
        case '+':
            if(lastToken != _NUM && lastToken != _ID && lastToken != _STRING) cout << "0 ";
            casa('+');
            T();
            cout << "+ ";
            E_linha();
            break;
        case '-':
            if(lastToken != _NUM && lastToken != _ID && lastToken != _STRING) cout << "0 ";
            casa('-');
            T();
            cout << "- ";
            E_linha();
            break;
    }
}

void T() {
  F();
  T_linha();
}

void T_linha(){
    switch(token) {
        case '*':
            casa('*');
            F();
            cout << "* ";
            T_linha();
            break;
        case '/':
            casa('/');
            F();
            cout << "/ ";
            T_linha();
            break;
    }
}

void F() {
    F_linha();
    U();
}

void F_linha(){
    switch(token) {
        case _ID:
            casa(_ID);
            if(token != '(') {
                print_lexema();
                cout << "@ ";
            } else {
                string temp = lexema;
                casa('(');
                cout << "Entrei aqui! " << token << " " << lexema << endl;
                E();
                P();
                casa(')'); 
                cout << temp + " " + "#" + " ";
            }
            break;
        case _NUM:
            casa(_NUM);
            print_lexema();
            F();
            break;
        case '(':
            casa('(');
            E();
            casa(')');
            break;
        case _STRING:
            casa(_STRING);
            print_lexema();
            break;
    }
}

void U() {
    C();
    switch(token) {
        case '^':
            casa('^');
            F();
            cout << "^ ";
            U();
            break;
    }
}

void C() {
    switch(token) {
        case '!':
            casa('!');
            F_linha();
            cout << "fat # ";
            C();
            break;
    }
}

void P(){
    if(token == ','){
        casa(',');
        E();
        P();
    }
}

void casa( int esperado ) {
  if( token == esperado ){
    lexema = yytext;
    token = next_token();
  }
}

int main() {
  token = next_token();
  lexema = yytext;
  B();  
  return 0;
}