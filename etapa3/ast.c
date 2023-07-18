#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ast.h"

ast_t *ast_new(lexical_value_t lexical_value)
{
  ast_t *new = calloc(1, sizeof(ast_t));
  if (new != NULL) {
    new->lexical_value = lexical_value;
    new->number_of_children = 0;
    new->next = NULL;
    new->children = NULL;
  }
  return new;
}

void ast_update_label(ast_t *tree, char *new_label)
{
  if (tree != NULL) {
    free(tree->lexical_value.label);
    tree->lexical_value.label = new_label;
  }
}

void ast_add_child(ast_t *tree, ast_t *child)
{
  if (tree != NULL && child != NULL) {
    tree->number_of_children++;
    tree->children = realloc(tree->children, tree->number_of_children * sizeof(ast_t*));
    tree->children[tree->number_of_children-1] = child;
  }
}

void ast_append_next(ast_t *tree, ast_t *next)
{
  ast_t* aux = tree;
  if (tree != NULL && next != NULL) {
    while (aux->next != NULL) {
      aux = aux->next;
    }
    aux->next = next;
  }
}

void exporta(ast_t *tree)
{
  if (tree != NULL) {
    printf("%p [label=\"%s\"];\n", tree, tree->lexical_value.label);
    for (int i = 0; i < tree->number_of_children; i++) {
      printf("%p, %p\n", tree, tree->children[i]);
      exporta(tree->children[i]);
    }
    if (tree->next != NULL) {
      printf("%p, %p\n", tree, tree->next);
      exporta(tree->next);
    }
  }
}

void ast_free(ast_t *tree)
{
  if (tree != NULL) {
    for (int i = 0; i < tree->number_of_children; i++) {
      ast_free(tree->children[i]);
    }
    ast_free(tree->next);
    free(tree->children);
    free(tree->lexical_value.label);
    free(tree);
  }
}