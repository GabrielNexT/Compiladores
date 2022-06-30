WS  [ \t]
D   [0-9]
L   [A-Za-z]

INT [1-9]+[0-9]*|0
FLOAT {D}+((\.?{D}+([eE]?[+-]?{D}*)?)|e[+-]?{D})

ID  (_|\$|{L})+(_|{L}|{D})*

STRING '([^'\n\\]|(\\')|''|'\\\\')+\'|\"([^\"\n\\]|(\\\")|\"\"|"\\\\")+\"

LT      "<="
LE      ">="
EQ      "=="
NE      "!="

PE      "+="

OR      ({LT}|{LE}|{EQ}|{NE})

BL      "\n"

FOR     "for"
WHILE   "while"

IF      "if"
ELSE    "else"
ELSEIF  "else if"

DV      "var"
DL      "let"
DC      "const"

%%

{WS}    {

}

{OR}    { 
    yylval.c = novo + yytext;
    return OR_T;
}

{BL}        {
    currentLine++;
}

{DV}    {
    return DV_T;
}

{DL}    {
    return DL_T;
}

{DC}    {
    return DC_T;
}

{PE}    {
    return PE_T;
}

{FOR}   {
    return FOR_T;
}

{WHILE} {
    return WHILE_T;
}

{IF}    {
    return IF_T;
}

{ELSE}  {
    return ELSE_T;
}

{ELSEIF}    {
    return ELSEIF_T;
}

{INT}   {
    yylval.c = novo + yytext; return NUM_T; 
}

{FLOAT} {
    yylval.c = novo + yytext; return NUM_T; 
}

{ID}    {
    yylval.c = novo + yytext; return ID_T; 
}

{STRING}    {
    yylval.c = novo + yytext; return STRING_T;
}

.   {
    yylval.c = novo + yytext; return yytext[0]; 
}

%%