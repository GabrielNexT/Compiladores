all: compilador input.txt
	./jsCompiler < input.txt > output.txt

lex.yy.c: scan.lex
	lex scan.lex

y.tab.c: compilador.y
	yacc compilador.y

compilador: lex.yy.c y.tab.c
	g++ -o jsCompiler y.tab.c -ll

clean:
	rm -rf y.tab.c lex.yy.c compilador output.txt