
//-----------------------------------------------------------------------------
//   IntegerLinkedList.c
//   Implementation file for IntegerLinkedList ADT
//-----------------------------------------------------------------------------
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<assert.h>
#include"IntegerLinkedList.h"

// private types --------------------------------------------------------------

// NodeObj
typedef struct NodeObj{
   int item;
   struct NodeObj* next;
} NodeObj;

// Node
//see .h file for defn

// newNode()
// constructor of the Node type
Node newNode(int x) {
   Node N = malloc(sizeof(NodeObj));
   assert(N!=NULL);
   N->item = x;
   N->next = NULL;
   return(N);
}

// freeNode()
// destructor for the Node type
void freeNode(Node *pN){
   if( pN!=NULL && *pN!=NULL){
      free(*pN);
      *pN = NULL;
   }
}

// LinkedListObj
typedef struct LinkedListObj{
   Node top;
   int numItems;
} LinkedListObj;

// public functions -----------------------------------------------------------

// newLinkedList()
// constructor for the LinkedList type
LinkedList newLinkedList(void){
   LinkedList S = malloc(sizeof(LinkedListObj));
   assert(S!=NULL);
   S->top = NULL;
   S->numItems = 0;
   return S;
}

// freeLinkedList()
// destructor for the LinkedList type
void freeLinkedList(LinkedList* pS){
   if( pS!=NULL && *pS!=NULL)
   {
	  Node N = (*pS)->top;
	  Node temp;
      while(N != NULL)
	  {
		temp = N->next;
	  	freeNode(&N);
		N = temp;
	  }
	  freeNode(&N);
	  free(*pS);
      *pS = NULL;
   }
}
//-----------------------------------------------------------------------------
// definitions of ADT operations (only giving printLinkedList, you need to do the rest)
//-----------------------------------------------------------------------------

// printLinkedList()
// prints a text representation of S to the file pointed to by out
// pre: none
void printLinkedList(FILE* out, LinkedList S){
   Node N;
   if( S==NULL ){
      fprintf(stderr,
              "LinkedList Error: calling printLinkedList() on NULL LinkedList reference\n");
      exit(EXIT_FAILURE);
   }
   for(N=S->top; N!=NULL; N=N->next)
   {
	   if(N->next != NULL)
	   {
	   		fprintf(out, "%d -> ", N->item);
	   }
	   else
	   {
	   		fprintf(out, "%d", N->item);
	   }
   }
   fprintf(out, "\n");
}
