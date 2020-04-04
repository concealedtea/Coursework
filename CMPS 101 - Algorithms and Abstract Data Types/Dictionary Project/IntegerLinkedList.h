//-----------------------------------------------------------------------------
// IntegerLinkedList.h
// Header file for the IntegerLinkedList ADT
//-----------------------------------------------------------------------------

#ifndef _INTEGER_LINKEDLIST_H_INCLUDE_
#define _INTEGER_LINKEDLIST_H_INCLUDE_

#include<stdio.h>

// LinkedList
// Exported reference type
typedef struct LinkedListObj* LinkedList;

// Node
// Exported reference type
typedef struct NodeObj* Node;

//constructor for node
Node newNode(int x);

// newLinkedList()
// constructor for the LinkedList type
LinkedList newLinkedList(void);

// freeLinkedList()
// destructor for the LinkedList type
void freeLinkedList(LinkedList* pS);

//-----------------------------------------------------------------------------
// prototypes of ADT operations deleted to save space, see webpage
//-----------------------------------------------------------------------------

void addNode(Node N, LinkedList S);

void printList(LinkedList S);


// printLinkedList()
// prints a text representation of S to the file pointed to by out
// pre: none
void printLinkedList(FILE* out, LinkedList S);

// insert()
// insert number into linked list
// pre: none
void insert(int number, LinkedList S);

// find()
// find pointer to node containing number (read next code snippet for details), return //      null if none exists
// pre: none
Node find(int number, LinkedList S);

// delete()
// delete number from linked list
// pre: none
void delete(int n, LinkedList S);

#endif
