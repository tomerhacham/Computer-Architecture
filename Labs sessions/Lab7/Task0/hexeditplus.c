#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>

#define STDIN 0


int debug = 0;

typedef struct {
  char debug_mode;
  char file_name[128];
  int unit_size;
  unsigned char mem_buf[10000];
  size_t mem_count;
  /*
   .
   .
   Any additional fields you deem necessary
  */
} state;


typedef struct {
  char *name;
  void (*fun)(state*);
}fun_desc;



void toggleDebugMode (state* s) {
  if (debug == 0) {
    printf("Debug flag now on\n");
    debug = 1;
  }
  else {
    printf("Debug flag now off\n");
    debug = 0;
  }
}

void setFileName (state* s) {
  printf("Enter the new file name : \n");

  char newFileName [100];
  fgets (newFileName , 100 , STDIN);

  strcpy (s->file_name , newFileName);

  if (debug) { printf("Debug: file name set to %s\n", newFileName);}
}

int isValidUnitSize (int num){
  if (num == 1 || num == 2 || num == 4) { return 1; }
  return 0;
}

void setUnitSize (state* s) {
  printf("Enter the new unit_size : \n");

  int newUnitSize = fgetc (STDIN);

  if (!isValidUnitSize (newUnitSize)){
     printf("Invalid number\n");
     return;
  }

  if (debug) { printf("Debug: file name set to %d\n", newUnitSize);}
}

void quit (state* s) {
    if (debug) { printf("quitting..\n");}
    exit(0);
}

void printDebugBeforeMenu (state* s){
    printf("unit_size : %d\n", s->unit_size );
    printf("file_name : %s\n", s->file_name );
    printf("mem_count : %d\n", s->mem_count );
}

void display (fun_desc menu[] , state* s){
    if (debug){
      printDebugBeforeMenu(s);
    }

    fprintf(stdout, "Please choose a function:\n");

    int i=0 ;
    while(menu[i].name != NULL) {
      fprintf(stdout, "%d) %s\n", i, menu[i].name);
      i++;
    }

    fprintf(stdout, "Option: ");
}

int getUserInput (int bounds){

  int op;
  scanf("%d", &op); //will throw exaption if its not a number, but we asume valid input (in the instraction)

  if (op >= 0 && op < bounds){
    fprintf(stdout, "Within bounds\n" );
    return op;

  }
  else{
    fprintf(stdout, "Not within bounds\n" );
    //exit (0);
    return -1;
  }

}


int main(int argc, char **argv){
  state* s = calloc (1 , sizeof(state));

  fun_desc menu[] = { { "Toggle Debug Mode", toggleDebugMode }, { "Set File Name", setFileName }, { "Set Unit Size", setUnitSize },
                                { "Quit", quit } ,{ NULL, NULL } };

  size_t bounds=0;
  while ( menu[bounds].name != NULL){
    bounds = bounds +1;
  }

  while (1) {

    display(menu , s);
    int option = getUserInput (bounds);
    if (option != -1) { menu[option].fun(s); }

    printf("\n");

  }


}
