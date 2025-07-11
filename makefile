# Nome do executável final
EXEC = meu_compilador

# Arquivos gerados automaticamente
BISON_SRC = parser.y
FLEX_SRC = lexer.lex

BISON_OUT_C = parser.tab.c
BISON_OUT_H = parser.tab.h
FLEX_OUT = lex.yy.c

# Diretiva principal (roda tudo exceto clean)
all: $(EXEC)
	clear
	@echo "Executando $(EXEC)..."
	./$(EXEC)

# Compilação
$(EXEC): $(BISON_SRC) $(FLEX_SRC)
	bison -d $(BISON_SRC)
	flex $(FLEX_SRC)
	gcc -o $(EXEC) $(FLEX_OUT) $(BISON_OUT_C) -lfl

# Limpeza dos arquivos gerados
clean:
	rm -f $(EXEC) $(BISON_OUT_C) $(BISON_OUT_H) $(FLEX_OUT)
	clear
