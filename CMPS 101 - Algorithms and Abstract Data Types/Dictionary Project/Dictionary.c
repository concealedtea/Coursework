
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<assert.h>
#include"Dictionary.h"

typedef struct NodeObj{
   int item;
   struct NodeObj* next;
} NodeObj;

Node newNode(int x) {
   Node N = malloc(sizeof(NodeObj));
   assert(N!=NULL);
   N->item = x;
   N->next = NULL;
   return(N);
}

void freeNode(Node *pN){
   if( pN!=NULL && *pN!=NULL){
      free(*pN);
      *pN = NULL;
   }
}

typedef struct LinkedListObj{
   Node top;
   int numItems;
} LinkedListObj;

LinkedList newLinkedList(void){
   LinkedList S = malloc(sizeof(LinkedListObj));
   assert(S!=NULL);
   S->top = NULL;
   S->numItems = 0;
   return S;
}

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
Node find(int number, LinkedList S)
{
	Node N;
	for(N=S->top; N!=NULL; N=N->next)
	{
		if(N->item == number)
		{
			return N;
		}
	}
	return NULL;
}

void addNode(Node N, LinkedList S)
{
	Node currentNode;
	if(S->top == NULL)
	{
		S->top = N;
	}
	else
	{
		currentNode = S->top;
		while(currentNode->next != NULL)
		{
			currentNode = currentNode->next;
		}
		currentNode->next = N;
	}
	S->numItems++;
}

void insert(int num, LinkedList S)
{
	Node N = newNode(num);
	Node currentNode;
	if(S->top == NULL)
	{
		S->top = N;
	}
	else
	{
		currentNode = S->top;
		while(currentNode->next != NULL)
		{
			currentNode = currentNode->next;
		}
		currentNode->next = N;
	}
	S->numItems++;
}

void printList(LinkedList S)
{
	Node temp = S->top;

	while(temp != NULL)
	{
		printf("%d ->", temp->item);
		temp = temp->next;
	}
	printf("\n");
}

void delete(int n, LinkedList S)
{
	Node N;
	Node prev;
	for(N=S->top; N!=NULL; N=N->next)
	{
		if(N->item == n)
		{
			if(N == S->top)
			{
				S->top = N->next;
			}
			else
			{
				prev->next = N->next;
			}
			freeNode(&N);
			break;
		}
		prev = N;
	}
}

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
