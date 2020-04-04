#ifndef _DICTIONARY_H_INCLUDE_
#define _DICTIONARY_H_INCLUDE_

#include<stdio.h>

typedef struct LinkedListObj* LinkedList;

typedef struct NodeObj* Node;

Node newNode(int x);

LinkedList newLinkedList(void);

void freeLinkedList(LinkedList* pS);

void addNode(Node N, LinkedList S);

void printList(LinkedList S);

void printLinkedList(FILE* out, LinkedList S);

void insert(int number, LinkedList S);

Node find(int number, LinkedList S);

void delete(int n, LinkedList S);

#endif
