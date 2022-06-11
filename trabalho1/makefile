all: compile input.txt
	./a.out < input.txt > output.txt

lex:
	lex scan.lex

compile: lex main.cc
	g++ main.cc -lfl
	
clean:
	rm a.out lex.yy.c
	