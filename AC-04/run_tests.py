#!/usr/bin/env python3
"""
Script de testes para a gramatica RbtLang (ANTLR + Python3).

Uso:
    uv run python run_tests.py
"""

import glob
import os
import subprocess
import sys

# Diretorios e caminhos do projeto
PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
GEN_DIR = os.path.join(PROJECT_ROOT, "generated")
GRAMMAR_DIR = os.path.join(PROJECT_ROOT, "grammar")
TOOLS_DIR = os.path.join(PROJECT_ROOT, "tools")
TEST_DIR = os.path.join(PROJECT_ROOT, "tests")
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "outputs")

GRAMMAR_FILE = os.path.join(GRAMMAR_DIR, "RbtLang.g4")
ANTLR_JAR = os.path.join(TOOLS_DIR, "antlr-4.13.2-complete.jar")
GENERATED_FILES = [
    os.path.join(GEN_DIR, "RbtLangLexer.py"),
    os.path.join(GEN_DIR, "RbtLangParser.py"),
    os.path.join(GEN_DIR, "RbtLangVisitor.py"),
]


def regenerate_parser():
    """
    Regenera os arquivos do parser a partir do .g4 caso estejam
    desatualizados ou inexistentes.
    """
    grammar_mtime = os.path.getmtime(GRAMMAR_FILE)
    needs_regen = False

    for gen_file in GENERATED_FILES:
        if not os.path.exists(gen_file):
            needs_regen = True
            break
        if os.path.getmtime(gen_file) < grammar_mtime:
            needs_regen = True
            break

    if not needs_regen:
        print("[INFO] Arquivos do parser estao atualizados. Pulando regeneracao.")
        return

    print("[INFO] Gramatica modificada ou arquivos ausentes. Regenerando parser...")
    cmd = [
        "java",
        "-jar",
        ANTLR_JAR,
        "-Dlanguage=Python3",
        "-no-listener",
        "-visitor",
        "-o",
        GEN_DIR,
        GRAMMAR_FILE,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print("[ERRO] Falha ao regenerar parser:")
        print(result.stderr)
        sys.exit(1)
    print("[OK] Parser regenerado com sucesso.")


# Regenera se necessario ANTES de importar os modulos gerados
regenerate_parser()

# Garante que os modulos gerados pelo ANTLR em generated/ sejam encontrados
sys.path.insert(0, GEN_DIR)

from antlr4 import *
from antlr4.error.ErrorListener import ErrorListener
from antlr4.tree.Trees import Trees

from RbtLangLexer import RbtLangLexer
from RbtLangParser import RbtLangParser


class CollectingErrorListener(ErrorListener):
    """Coleta mensagens de erro do ANTLR sem imprimir no stderr."""

    def __init__(self):
        self.errors = []

    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        self.errors.append(f"line {line}:{column} {msg}")


def parse_source(source_code: str) -> str:
    """
    Faz o parsing do codigo fonte e retorna a arvore sintatica
    no formato LISP. Levanta excecao se houver erros lexicos ou sintaticos.
    """
    lexer_errors = CollectingErrorListener()
    parser_errors = CollectingErrorListener()

    input_stream = InputStream(source_code)
    lexer = RbtLangLexer(input_stream)
    lexer.removeErrorListeners()
    lexer.addErrorListener(lexer_errors)

    tokens = CommonTokenStream(lexer)
    parser = RbtLangParser(tokens)
    parser.removeErrorListeners()
    parser.addErrorListener(parser_errors)

    tree = parser.program()

    all_errors = lexer_errors.errors + parser_errors.errors
    if all_errors:
        raise Exception("\n".join(all_errors))

    return Trees.toStringTree(tree, recog=parser)


def run_tests():
    """
    Executa todos os casos de teste encontrados em TEST_DIR.
    Sai com codigo 1 se algum teste falhar.
    """
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    test_files = sorted(glob.glob(os.path.join(TEST_DIR, "*.in")))
    if not test_files:
        print(f"Nenhum arquivo de teste encontrado em '{TEST_DIR}/'")
        sys.exit(1)

    print("=" * 56)
    print("  EXECUCAO DOS TESTES - RBTLANG (Python3)")
    print("=" * 56)
    print()

    failures = 0

    for testfile in test_files:
        basename = os.path.splitext(os.path.basename(testfile))[0]
        with open(testfile, "r", encoding="utf-8") as f:
            source_code = f.read().strip()

        print("-" * 56)
        print(f"Teste: {basename}")
        print(f"Codigo: {source_code}")
        print()

        try:
            tree_str = parse_source(source_code)
            output_path = os.path.join(OUTPUT_DIR, f"{basename}.out")
            with open(output_path, "w", encoding="utf-8") as out:
                out.write(tree_str + "\n")

            print("[OK] Parsing bem-sucedido")
            print(f"Arvore sintatica salva em: {output_path}")
            print()
            print("Arvore:")
            print(tree_str)
        except Exception as e:
            failures += 1
            print(f"[ERRO] Falha no parsing:")
            print(str(e))

        print()

    print("=" * 56)
    if failures:
        print(f"  {failures} TESTE(S) FALHOU/FALHARAM")
        print("=" * 56)
        sys.exit(1)
    else:
        print("  TODOS OS TESTES CONCLUIDOS")
        print("=" * 56)


if __name__ == "__main__":
    run_tests()
