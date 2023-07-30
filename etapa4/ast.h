#ifndef _AST_H_
#define _AST_H_

typedef enum token_type {
  SPECIAL,
  RESERVERD_WORD,
  COMPOUND_OPERATOR,
  IDENTIFIER,
  LITERAL
} token_type_t;

typedef enum {
    INT,
    FLOAT,
    BOOL
} E_Type;

typedef struct lexical_value {
  char *label;
  int line;
  token_type_t type;
} lexical_value_t;

typedef struct ast {
  E_Type e_type;
  lexical_value_t lexical_value;
  int number_of_children;
  struct ast *next;
  struct ast **children;
} ast_t;

/*
 * Função ast_new, cria um nó sem filhos com o label informado.
 */
ast_t *ast_new(lexical_value_t lexical_value);

/*
 * Função ast_update_label, muda o label de um nó
 */
void ast_update_label(ast_t *tree, char *new_label);

/*
 * Função ast_add_child, adiciona child como filho de tree.
 */
void ast_add_child(ast_t *tree, ast_t *child);

/*
 * Função append_next, adiciona next ao fim da lista de next.
 */
void ast_append_next(ast_t *tree, ast_t *next);

/*
 * Função exporta, imprime recursivamente os vertices e as arestas da árvore.
 */
void exporta(ast_t *tree);

/*
 * Função ast, libera recursivamente o nó e seus filhos.
 */
void ast_free(ast_t *tree);

#endif //_AST_H_