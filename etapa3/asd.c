#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "asd.h"
#define ARQUIVO_SAIDA "saida.dot"

asd_tree_t *asd_new(const char *label)
{
  asd_tree_t *ret = NULL;
  ret = calloc(1, sizeof(asd_tree_t));
  if (ret != NULL){
    ret->label = strdup(label);
    ret->number_of_children = 0;
    ret->next = NULL;
    ret->children = NULL;
  }
  return ret;
}

void asd_free(asd_tree_t *tree)
{
  if (tree != NULL) {
    int i;
    for (i = 0; i < tree->number_of_children; i++) {
      asd_free(tree->children[i]);
    }
    free(tree->children);
    free(tree->next);
    free(tree->label);
    free(tree);
  }
}

void asd_add_child(asd_tree_t *tree, asd_tree_t *child)
{
  if (tree != NULL && child != NULL) {
    tree->number_of_children++;
    tree->children = realloc(tree->children, tree->number_of_children * sizeof(asd_tree_t*));
    tree->children[tree->number_of_children-1] = child;
  }
}

void asd_append_next(asd_tree_t *tree, asd_tree_t *next)
{
  asd_tree_t* aux = tree;
  if (tree != NULL && next != NULL) {
    while (aux->next != NULL) {
      aux = aux->next;
    }
    aux->next = next;
  }
}

void exporta(asd_tree_t *tree)
{
  if (tree != NULL) {
    printf("%p [label=\"%s\"];\n", tree, tree->label);
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