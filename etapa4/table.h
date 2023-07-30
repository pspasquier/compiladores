#ifndef _TABLE_H_
#define _TABLE_H_

#define ERR_UNDECLARED 10 //2.2
#define ERR_DECLARED 11 //2.2
#define ERR_VARIABLE 20 //2.3
#define ERR_FUNCTION 21 //2.3

typedef enum {
    false = 0,
    true = 1
} bool;

typedef enum {
    LITERAL_TYPE,
    IDENTIFICADOR,
    FUNCAO
} Nature;

typedef enum {
    INT,
    FLOAT,
    BOOL
} E_Type;

typedef struct {
    char* id;
    int linha;
    Nature nature;
    E_Type e_type;
} SymbolEntry;

typedef struct Node {
    SymbolEntry entry;
    struct Node* next;
} Node;

typedef struct {
    Node* head;
    Node* tail;
} SymbolList;

typedef struct NodeS{
    SymbolList* symbolList;
    struct NodeS* next;
} NodeS;

typedef struct {
    NodeS* top;
} SymbolStack;

extern SymbolStack* stack; // global stack

// Function to create a new node
Node* createNode(SymbolEntry entry);

// Function to create an empty list
SymbolList* createList();

// Function to check if the list is empty
int isEmpty(SymbolList* list);

// Function to add an element to the end of the list
void append(SymbolList* list, SymbolEntry entry);

// Function to delete the entire list and free memory
void deleteList(SymbolList* list);

// -- STACK ------------------------------------------------------------

// Function to create an empty NodeS (with a NULL SymbolList)
NodeS* createNodeS();

// Function to create an empty stack
SymbolStack* createStack();

// Function to check if the stack is empty
int isEmptyS();

// Function to push a symbol list onto the stack
void push();

// Function to pop the top NodeS from the stack
void pop();

// Function to delete the entire stack and free memory
void deleteStack();

// Function to find an element in the symbol lists of the stack
SymbolEntry* findFirstDeclaration(char* id);

// Function to find an element in the symbol list of the top node in the stack
bool isAlreadyDeclared(const char* id);

// append entry to the symbol list if it is undeclared there
void addEntryToScope(const char* id, int linha, Nature nature, E_Type e_type);

// --PRINT FUNCTIONS----------------------------------------------------------------------

// Function to print a single SymbolEntry
void printSymbolEntry(SymbolEntry entry);

// Function to print all elements of a SymbolList
void printSymbolList(SymbolList* list);

// Function to print all elements of the stack
void printStack();


#endif //_TABLE_H_