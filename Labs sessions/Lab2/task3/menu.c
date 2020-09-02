#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define LENGTH(x)  (sizeof(x) / sizeof((x)[0]))
#define arrLength 5

struct fun_desc {
  char *name;
  char (*fun)(char);
};

char censor(char c) {
  if(c == '!')
    return '.';
  else
    return c;
}

/* Gets a char c and returns its encrypted form by adding 3 to its value.
If c is not between 0x20 and 0x7E it is returned unchanged */
char encrypt(char c) {
  if(c<=0x7E && c>=0x20)
    c=c+3;
  return c;
}
/* Gets a char c and returns its decrypted form by reducing 3 to its value.
 If c is not between 0x20 and 0x7E it is returned unchanged */
char decrypt(char c){
  if(c<=0x7E && c>=0x20)
    c=c-3;
  return c;
}
/* dprt prints the value of c in a decimal representation followed by a
new line, and returns c unchanged. */
char dprt(char c){
  printf("%d\n",c );
  return c;
}
/* If c is a number between 0x20 and 0x7E, cprt prints the character of ASCII value c followed
by a new line. Otherwise, cprt prints the dot ('.') character. After printing, cprt returns
value of c unchanged. */
char cprt(char c){
  if(c<=0x7E && c>=0x20)
    printf("%c\n",c );
    else
    printf(".");
  return c;
}
/* Ignores c, reads and returns a character from stdin using fgetc. */
char my_get(char c){
  return fgetc(stdin);
}

char* map(char *array, int array_length, char (*f) (char)){
  char* mapped_array = (char*)(malloc(array_length*sizeof(char)));
  for(int i=0;i<array_length;i++){
    mapped_array[i]=(*f)(array[i]);
  }
  return mapped_array;
}

 /* Gets a char c,  and if the char is 'q' , ends the program with exit code 0. Otherwise returns c. */
char quit(char c){
  if(c=='q')
    exit(EXIT_SUCCESS);
    else
    return c;
}

void clear_string(char* string){
  *string='\0';
  return;
}

int get_input_and_check_bounds(size_t size){
  char picked_option;
  printf("Option: ");
  picked_option=fgetc(stdin);
  picked_option=picked_option-48;
  if(picked_option>=0 && picked_option<size)
    printf("Within bounds\n");
  else{
    printf("Not within bounds\n");
    picked_option=-1;//indicate to exit after freeing the memory allocated by malloc
  }
  return picked_option;
}

int main(int argc, char **argv){
  char picked_option;
  char* carray = (char*)(malloc(5*sizeof(char)));
  struct fun_desc menu[] = { { "Censor", censor },{ "Encrypt", encrypt },
                             { "Decrypt", decrypt },{ "Print dec", dprt },
                             { "Print string", cprt },{ "Get string", my_get },
                             { "Quit", quit }, { NULL, NULL } };

  size_t array_length = LENGTH(menu)-1;
  clear_string(carray);
  while(1){
    printf("Please choose a function:\n");
    for(int i=0;i<array_length;i++){
        printf("%d) %s\n",i,menu[i].name );
    }
    picked_option=get_input_and_check_bounds(array_length);
    if(picked_option==-1){
      free(carray);
      exit(EXIT_SUCCESS);
    }
    else{
      fgetc(stdin);//get rid of the newline char
      carray = map(carray,arrLength,menu[(int)picked_option].fun);
      printf("DONE.\n\n");

    }
  }
}
