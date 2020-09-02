#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
#include <elf.h>



int debug = 0;
int displayMode = 0;

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


//copied from the given example
char* unit_to_format(int unit_size ) {
    static char* formats_hex[] = {"%#hhx\n", "%#hx\n", "No such unit", "%#x\n"};
    static char* formats_decimal[] = {"%#hhd\n", "%#hd\n", "No such unit", "%#d\n"};

    if (displayMode) { return formats_hex[unit_size-1]; }
    else {return formats_decimal[unit_size-1];}

}

//copied from the given example
void print_units(FILE* output, void* buffer, int count , int unit_size) {
    void* end = buffer + unit_size*count;
    while (buffer < end) {
        //print ints
        int var = *((int*)(buffer));
        fprintf(output, unit_to_format(unit_size), var);
        buffer += unit_size;
    }
}

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

  char newFileName [1024];
  fscanf(stdin , "%s" , newFileName);

  strcpy (s->file_name , newFileName);

  if (debug) { fprintf(stderr , "Debug: file name set to %s\n", newFileName);}
}

int isValidUnitSize (int num){
  if (num == 1 || num == 2 || num == 4) { return 1; }
  return 0;
}

void setUnitSize (state* s) {
  //read from user
  fprintf(stdout, "Enter the new unit_size :\n");
  int newUnitSize =0;
  fscanf(stdin , "%d" , &newUnitSize);

  if (debug) { fprintf(stderr , "Debug: unit_size set to %d\n", newUnitSize);}

  if (!(isValidUnitSize (newUnitSize))){
     printf("Invalid number\n");
     return;
  }
  s->unit_size = newUnitSize;
  
}

void LoadIntoMemory (state* s) {
  //check valid file name
  if (strcmp (s->file_name , "") ==0 ){
    printf("File name is empty\n");
    return;
  }

  //open the file
  FILE* fd = fopen(s-> file_name, "r+");
  if (fd == NULL) {
    printf("Error open file\n");
    return;
  }

  //get args from user
  fprintf(stdout, "Please enter <location> <length> : \n");
  
  int location=0;
  int length=0;
  fscanf(stdin , "%x %d" ,&location , &length);
 
  if (debug) {
    fprintf(stderr, "File name : %s\n", s-> file_name);
    fprintf(stderr, "Location : %d\n", location);
    fprintf(stderr, "Length : %d\n", length);
  }

  fseek (fd, location, SEEK_SET);
  s->mem_count = s->unit_size*length;
  fread (s->mem_buf , s->unit_size , length , fd);
  fclose (fd);

  fprintf(stdout, "Loaded %d units into memory.\n" , length);

}

void ToggleDisplayMode (state* s) {
  if (displayMode == 0) {
    printf("Display flag now on, hexadecimal representation\n");
    displayMode = 1;
  }
  else {
    printf("Display flag now off, decimal representation\n");
    displayMode = 0;
  }
}

void MemoryDisplay (state* s) {

  fprintf(stdout, "Please enter <num of units to display> <address in memory> :\n");
  int u =0;
  int address =0;

  fscanf(stdin , "%d %x" ,&u , &address); 

  if (displayMode) { printf ("Hexadecimal\n===========\n"); }
  else{ printf ("Decimal\n=======\n"); }
  
  if (address ==0 ) {print_units (stdout , &(s->mem_buf) ,u , s->unit_size);}
  else { print_units (stdout , &(address) ,u , s->unit_size); }

}

void SaveIntoFile (state* s) {
  fprintf(stdout, "Please enter <source-address> <target-location> <length>:\n");
  int source_address =0;
  int target_location =0;
  int length =0;

  fscanf(stdin , "%x %x %d" ,&source_address , &target_location , &length); 

  FILE* fd = fopen(s-> file_name, "r+");
  if (fd == NULL) {
    printf("Error open file\n");
    return;
  }

  fseek (fd, 0, SEEK_END);
  int end = ftell (fd);

  if (end < target_location) { 
    perror ("offest is gratter then file size");
    return;
  }

  fseek (fd, 0, SEEK_SET); //back to start of file

  fseek (fd, target_location, SEEK_SET);

  if (source_address ==0 ) {fwrite (&(s->mem_buf) , s->unit_size , length , fd); }
  else { fwrite (& (source_address) , s->unit_size , length , fd); }

  close(fd);
}

void MemoryModify (state* s) {
  
  //get args from user
  fprintf(stdout, "Please enter <location> <val>: \n");
  
  int location=0;
  int val=0;
  fscanf(stdin , "%x %x" ,&location , &val);


  if (debug){
      printf("Location: %x\nVal: %x\n", location, val);
  }

  //change to new val
  memcpy(&s->mem_buf[location], &val, s->unit_size);

}

void quit (state* s) {
    if (debug) { fprintf(stderr, "quitting..\n");}
    exit(0);
}

void printDebugBeforeMenu (state* s){
    fprintf(stderr , "unit_size : %d\n", s->unit_size );
    fprintf(stderr , "file_name : %s\n", s->file_name );
    fprintf(stderr , "mem_count : %d\n\n", s->mem_count );
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
    fprintf(stdout, "Within bounds\n\n" );
    return op;

  }
  else{
    fprintf(stdout, "Not within bounds\n\n" );
    //exit (0);
    return -1;
  }

}


int main(int argc, char **argv){
  state* s = calloc (1 , sizeof(state));

  fun_desc menu[] = { { "Toggle Debug Mode", toggleDebugMode }, { "Set File Name", setFileName }, { "Set Unit Size", setUnitSize },
                            { "Load Into Memory", LoadIntoMemory }, { "Toggle Display Mode", ToggleDisplayMode }, { "Memory Display", MemoryDisplay }
                            ,{ "Save Into File", SaveIntoFile } , { "Memory Modify", MemoryModify } ,{ "Quit", quit } ,{ NULL, NULL } };

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
