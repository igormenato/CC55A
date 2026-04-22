# AC-04 – Gramática ANTLR para `rbtlang`

**Disciplina:** Compiladores – 2026.1
**Professor:** Gleifer Vaz Alves

---

## 1. O que é

Implementação da gramática da linguagem **`rbtlang`** usando ANTLR 4 com target Python3.

`rbtlang` é uma linguagem simples para programar um robô que se move em quatro direções (`up`, `down`, `left`, `right`), encontra obstáculos (`obst`) e caixas (`box`), podendo coletar (`collect`) ou empurrar (`push`).

## 2. Gramática

| Regra       | Descrição                           |
| ----------- | ----------------------------------- |
| `program`   | `statement` separados por `,`       |
| `statement` | `move(...)` ou `if ... then ...`    |
| `move`      | `move(direção, INT)`                |
| `direction` | `up` \| `down` \| `left` \| `right` |
| `ifStmt`    | `if condition then action`          |
| `condition` | `obst` \| `box`                     |
| `action`    | `move(...)` \| `collect` \| `push`  |

**Tokens:** `INT` = `[0-9]+`, `WS` = ignorado.

## 3. Como executar

### Pre-requisitos

- [uv](https://docs.astral.sh/uv/)
- Java (para rodar o ANTLR em `tools/`)

### Rodar os testes

```bash
uv sync
uv run python run_tests.py
```

O script faz tudo automaticamente:

1. Compara timestamps do `.g4` com os arquivos em `generated/`
2. Regenera o parser via `java -jar tools/antlr-4.13.2-complete.jar` se necessário
3. Roda todos os testes em `tests/`
4. Salva as árvores sintáticas em `outputs/`
5. Imprime resultado no terminal

## 4. Casos de Teste

### Validos (15)

| #     | Arquivo                          | O que testa                     |
| ----- | -------------------------------- | ------------------------------- |
| 01-04 | `01_move_up` ... `04_move_right` | Movimentos nas 4 direções       |
| 05    | `05_sequence_two`                | Sequência de 2 movimentos       |
| 06    | `06_sequence_four`               | Sequência de 4 movimentos       |
| 07    | `07_if_obst_then_move`           | `if obst then move(...)`        |
| 08    | `08_if_box_then_collect`         | `if box then collect`           |
| 09    | `09_if_box_then_push`            | `if box then push`              |
| 10-12 | `10_move_then_if_*`              | Movimentos + condicionais       |
| 13    | `13_two_ifs`                     | Duas condicionais               |
| 14    | `14_complex_sequence`            | Sequência mista complexa        |
| 15    | `15_if_box_then_move`            | Ação condicional como movimento |

### Invalidos (3)

| Arquivo                      | Erro                           |
| ---------------------------- | ------------------------------ |
| `invalid_01_missing_comma`   | Falta vírgula entre comandos   |
| `invalid_02_wrong_direction` | Direção inválida (`front`)     |
| `invalid_03_wrong_condition` | Condição inválida (`obstacle`) |

## 5. Resultados

As árvores sintáticas em formato LISP são salvas em `outputs/` (ex: `01_move_up.out`) e impressas no terminal durante a execução.
