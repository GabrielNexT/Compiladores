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
PP      "++"

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
    yylval.c = vector<string>() + yytext;
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

{PP}    {
    return PP_T;
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
    yylval.c = vector<string>() + yytext; return NUM_T; 
}

{FLOAT} {
    yylval.c = vector<string>() + yytext; return NUM_T; 
}

{ID}    {
    yylval.c = vector<string>() + yytext; return ID_T; 
}

{STRING}    {
    yylval.c = vector<string>() + yytext; return STRING_T;
}

.   {
    yylval.c = vector<string>() + yytext; return yytext[0]; 
}

%%