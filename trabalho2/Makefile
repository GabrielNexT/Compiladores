all: compile input.txt
	./a.out < input.txt

lex:
	lex scan.lex

compile: lex
	g++ lex.yy.c -ll
	
clean:
	rm a.out lex.yy.c
	