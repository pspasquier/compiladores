#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "table.h"

SymbolStack* stack = NULL; // global stack

// Function to create a new node
Node* createNode(SymbolEntry entry) {
    Node* newNode = (Node*)malloc(sizeof(Node));
    if (newNode != NULL) {
        newNode->entry = entry;
        newNode->next = NULL;
    }
    return newNode;
}


// Function to create an empty list
SymbolList* createList() {
    SymbolList* list = (SymbolList*)malloc(sizeof(SymbolList));
    if (list != NULL) {
        list->head = NULL;
        list->tail = NULL;
    }
    return list;
}

// Function to check if the list is empty
int isEmpty(SymbolList* list) {
    return list->head == NULL;
}

// Function to add an element to the end of the list
void append(SymbolList* list, SymbolEntry entry) {

    Node* newNode = createNode(entry);

    if (newNode != NULL) {
        // Copy the id string using strdup
        newNode->entry.id = strdup(entry.id);

        if (isEmpty(list)) {
            list->head = newNode;
            list->tail = newNode;
        } else {
            list->tail->next = newNode;
            list->tail = newNode;
        }
    }
}

// Function to delete the entire list and free memory
void deleteList(SymbolList* list) {
    Node* current = list->head;
    while (current != NULL) {
        Node* temp = current;
        current = current->next;
        free(temp->entry.id); // Free the memory for the id string
        free(temp);
    }
    free(list);
}

// -- STACK ------------------------------------------------------------

// Function to create an empty NodeS (with a NULL SymbolList)
NodeS* createNodeS() {
    NodeS* newNode = (NodeS*)malloc(sizeof(NodeS));
    if (newNode != NULL) {
        newNode->symbolList = (SymbolList*)malloc(sizeof(SymbolList));
        if (newNode->symbolList != NULL) {
            newNode->symbolList->head = NULL;
            newNode->symbolList->tail = NULL;
        } else {
            free(newNode);
            return NULL; // Memory allocation failed for newNode->symbolList
        }
        newNode->next = NULL;
    }
    return newNode;
}

// Function to create an empty stack
SymbolStack* createStack() {
    SymbolStack* stack = (SymbolStack*)malloc(sizeof(SymbolStack));
    if (stack != NULL) {
        stack->top = NULL;
    }
    return stack;
}

// Function to check if the stack is empty
int isEmptyS() {
    return stack->top == NULL;
}

// Function to push a symbol list onto the stack
void push() {
    NodeS* newNode = createNodeS();
    if (newNode != NULL) {
        newNode->next = stack->top;
        stack->top = newNode;
    }
}

// Function to pop the top NodeS from the stack
void pop() {
    if (stack == NULL || stack->top == NULL) {
        // Stack is empty or invalid, nothing to pop
        return;
    }

    NodeS* poppedNode = stack->top;
    stack->top = poppedNode->next;

    // Free the memory associated with the poppedNode
    deleteList(poppedNode->symbolList);
    free(poppedNode);
}

// Function to delete the entire stack and free memory
void deleteStack() {
    NodeS* current = stack->top;
    while (current != NULL) {
        NodeS* temp = current;
        current = current->next;
        // Free the memory for the symbol list and its elements
        deleteList(temp->symbolList);
        free(temp);
    }
    free(stack);
}

// Function to find an element in the symbol lists of the stack
SymbolEntry* findFirstDeclaration(char* id) {
    if (stack != NULL && stack->top != NULL) {
        NodeS* current = stack->top;
        while (current != NULL) {
            SymbolList* symbolList = current->symbolList;
            Node* listNode = symbolList->head;
            while (listNode != NULL) {
                
                if (strcmp(listNode->entry.id, id) == 0) {
                    return &listNode->entry;
                }
                
                listNode = listNode->next;
            }
            current = current->next;
        }
    }
    printf("entrada:%d: error: identifier '%s' is used without having been declared in any scope (ERR_UNDECLARED)\n", 111111, id);
    deleteStack(); // Delete the entire stack and free memory before exiting
    exit(ERR_UNDECLARED);
}

// Function to find an element in the symbol list of the top node in the stack
bool isAlreadyDeclared(const char* id) {
    if (stack == NULL || stack->top == NULL) {
        return false; // Stack is empty or invalid, element not found
    }

    SymbolList* symbolList = stack->top->symbolList;
    Node* listNode = symbolList->head;
    while (listNode != NULL) {
        if (strcmp(listNode->entry.id, id) == 0) {
            return true;
        }
        listNode = listNode->next;
    }

    return false; // Element not found in the top SymbolList
}

// append entry to the symbol list if it is undeclared there
void addEntryToScope(const char* id, int linha, Nature nature, E_Type e_type) {
    
    // Check if the identifier is already declared in the top symbol list
    if (!isAlreadyDeclared(id)) {
        
        SymbolEntry entry; 
        entry.id = strdup(id);
        entry.linha = linha;
        entry.nature = nature;
        entry.e_type = e_type;
        
        // Append theentry to the top symbol list
        append(stack->top->symbolList, entry);
    } else {
        printf("entrada:%d: error: identifier '%s' has already been declared again in the local scope (ERR_DECLARED)\n", 111111, id);
        deleteStack(); // Delete the entire stack and free memory before exiting
        exit(ERR_DECLARED);
    }
}

// --PRINT FUNCTIONS----------------------------------------------------------------------

// Function to print a single SymbolEntry
void printSymbolEntry(SymbolEntry entry) {
    printf("ID: %s, Linha: %d, Natureza: %d, Tipo: %d\n", entry.id, entry.linha, entry.nature, entry.e_type);
}

// Function to print all elements of a SymbolList
void printSymbolList(SymbolList* list) {
    Node* current = list->head;
    while (current != NULL) {
        printSymbolEntry(current->entry);
        current = current->next;
    }
}

// Function to print all elements of the stack
void printStack() {
    printf("\nSTACK AS OF RIGHT NOW:\n");
    NodeS* current = stack->top;
    while (current != NULL) {
        printSymbolList(current->symbolList);
        printf("--------------------\n");
        current = current->next;
    }
}
