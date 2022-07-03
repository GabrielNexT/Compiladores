all: compilador input.txt
	./jsCompiler < input.txt > output.txt

test: compilador output.txt interpretador
	./jsCompiler < input.txt > output.txt
	./interpretador < output.txt

lex.yy.c: scanDaniel.lex
	lex scanDaniel.lex

y.tab.c: compiladorDaniel.y
	yacc compiladorDaniel.y

compilador: lex.yy.c y.tab.c
	g++ -o jsCompiler y.tab.c -ll

clean:
	rm -rf y.tab.c lex.yy.c compilador output.txt