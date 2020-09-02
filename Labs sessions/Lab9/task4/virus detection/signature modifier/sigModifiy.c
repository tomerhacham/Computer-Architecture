#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define virus_size 653

typedef struct virus {
    unsigned short SigSize; //2
    char virusName[16]; //16
    unsigned char* sig; //8
} virus;

int main(int argc, char const *argv[]) {
    FILE*   sigFile = fopen("signatures","a+");
    FILE*   infected = fopen("infected","r+");
    fseek(infected,-virus_size,SEEK_END);

    char* sig = (char*)malloc(virus_size);
    fread(sig,1,virus_size,infected);
    //fread(infected,sig,virus_size);
    char* name = "asmVirus";
    virus* new_virus = (virus*)malloc(sizeof(virus));

    new_virus->SigSize=virus_size;
    strcpy(new_virus->virusName,name);
    new_virus->sig=sig;

    fwrite(&(new_virus->SigSize),1,sizeof(unsigned short),sigFile);
    fwrite(&(new_virus->virusName),1,16,sigFile);
    fwrite(new_virus->sig,1,virus_size,sigFile);

    free(sig);
    free(new_virus);

    fclose(sigFile);
    fclose(infected);

    return 0;
}
