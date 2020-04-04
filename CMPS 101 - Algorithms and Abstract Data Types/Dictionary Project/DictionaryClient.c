/*
*  DictionaryClient.c
*  Creates Client for Dictionary ADT
*/

#include<stdio.h>
#include<stdlib.h>
#include"Dictionary.h"
int main(int argc, char* argv[]){
  int i, m, n, p, reader, value;
  FILE* in;
  FILE* out;
  LinkedList D = newLinkedList();
  /* check command line for correct number of arguments */
  if( argc != 3 )
  {
     printf("Usage: %s infile outfile\n", argv[0]);
     exit(EXIT_FAILURE);
  }
  /* open files for reading and writing */
  in = fopen(argv[1], "r");
  out = fopen(argv[2], "w");
  if( in==NULL ){
     printf("Unable to open file %s for reading\n", argv[1]);
     exit(EXIT_FAILURE);
  }
  if( out==NULL ){
     printf("Unable to open file %s for writing\n", argv[2]);
     exit(EXIT_FAILURE);
  }

  while (fscanf(in, "%c", &reader) != EOF){
    if (reader == 'p'){
      printLinkedList(out, D);
    }
    else {
      if (reader == 'i'){
        fscanf(in,"%d",&value);
        insert(value, D);
        fprintf(out,"inserted %d\n", value);
      }
      else if (reader == 'f'){
        fscanf(in,"%d", &value);
        if (find(value,D) != NULL){
          fprintf(out, "%d present \n", value);
        } else {
          fprintf(out, "%d not present \n", value);
        }
      }
      else if (reader == 'd'){
        fscanf(in,"%d", &value);
        if(find(value,D) != NULL){
          delete(value, D);
          fprintf(out, "deleted %d\n", value);
        }else{
          fprintf(out, " %d not found\n", value);
        }
      }
    }
  }
}
