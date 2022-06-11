
WS  [ \t\n]
D  [0-9]
L [A-Za-z]

_INT  [1-9]+[0-9]*|0
_FLOAT {D}+((\.?{D}+([eE]?[+-]?{D}*)?)|e[+-]?{D})

_FOR [Ff][oO][rR]
_IF [iI][fF]

_SHALOW_COMMENT (\/\/)+[^\n]*
_DEEP_COMMENT (\/\*)+[^\*]*[^\/]*(\*\/)+

_COMENTARIO {_SHALOW_COMMENT}|{_DEEP_COMMENT}

_STRING_SINGLE_QUOTE [']([^'\\]|\\.|\\\n|'')*[']
_STRING_DOUBLE_QUOTE ["]([^"\\]|\\.|\\\n|"")*["]
_STRING {_STRING_SINGLE_QUOTE}|{_STRING_DOUBLE_QUOTE}

_STRING2 (`)+[^`]*(`)+

_ID (_|\$|{L})+(_|{L}|{D})*

%%

{WS}	{ 
  /* ignora espaço */ 
}    

{_INT}	{
  return _INT;
}

{_FLOAT} {
  return _FLOAT;
}

{_FOR} {
  return _FOR;
}

{_IF} {
  return _IF;
}

{_COMENTARIO} {
  return _COMENTARIO;
}

">=" {
  return _MAIG;
}

"<=" {
  return _MEIG;
}

"==" {
  return _IG;
}

"!=" {
  return _DIF;
}

{_STRING} {
  return _STRING;
}

{_STRING2} {
  return _STRING2;
}

{_ID} {
  return _ID;
}

. { 
  return *yytext;
}

%%