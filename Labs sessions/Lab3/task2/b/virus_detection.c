#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define NOP 0x90

typedef struct virus {
    unsigned short SigSize; //2
    char virusName[16]; //16
    unsigned char* sig; //8
} virus;
typedef struct link link;
struct link {
    link *nextVirus;
    virus *vir;
};

typedef struct {
    char *name;
    link* (*fun)(link*, const char*);
}MenuItem;

FILE* openFile(const char* filename,char* mode){
    FILE* file;
    file = fopen(filename,mode);
    if(file==NULL){ // if a file can't be open
        fprintf(stderr,"Error in openning filename : %s\n",filename);
        exit(EXIT_FAILURE);
    }
    return file;
}

void PrintHex(FILE* output, unsigned char* buffer, unsigned short length) {
    for(int i=0;i<length;i++){
        fprintf(output,"%02hhX ",buffer[i]);
    }
    fprintf(output,"\n\n");
}
virus* readVirus(FILE* file){
    virus* virus  = malloc(sizeof(struct virus));
    if(fread(virus,1,18,file)!=0){
        virus->sig=malloc(virus->SigSize);
        fread(virus->sig,1,virus->SigSize,file);

    }
    return virus;
}

void printVirus(virus* virus, FILE* output){
    fprintf(output,"Virus name: %s\n", virus->virusName);
    fprintf(output,"Virus size: %d\n", virus->SigSize);
    fprintf(output,"signature:\n");
    PrintHex(output,virus->sig, virus->SigSize);
}

int get_file_size(FILE* file){
    fseek(file, 0L, SEEK_END);
    int file_size = ftell(file);
    rewind(file);
    return file_size;
}

/* Print the data of every link in list to the given stream. Each item followed by a newline character. */
void list_print(link *virus_list, FILE* stream){
    link* curr_link= virus_list;
    while(curr_link!=NULL){
        printVirus(curr_link->vir,stream);
        curr_link=curr_link->nextVirus;
    }
}

link* MakeNewNode(virus* data){
    link* new_node = malloc(sizeof(struct link));
    new_node->vir=data;
    new_node->nextVirus=NULL;
    return new_node;
}

/* Add a new link with the given data to the list
   (either at the end or the beginning, depending on what your TA tells you),
   and return a pointer to the list (i.e., the first link in the list).
   If the list is null - create a new entry and return a pointer to the entry.
reccursive function*/
link* list_append(link* virus_list, virus* data){
    if(virus_list==NULL){
        link* new_node = MakeNewNode(data);
        virus_list=new_node;
    }
    else{
        virus_list->nextVirus=list_append(virus_list->nextVirus,data);
    }
    return virus_list;
}

/* Free the memory allocated by the list. */
//recurrsive function
void list_free(link *virus_list){
    link* curr_node=virus_list;
    if(curr_node!=NULL){
        list_free(curr_node->nextVirus);
        free(curr_node->vir->sig);
        free(curr_node->vir);
        free(curr_node);
    }
    return;
}

//extract the input from the user, check if valid and return numeric value of it
int get_input_and_check_bounds(size_t size){
    int picked_option;
    printf("Option: ");
    //picked_option=fgetc(stdin);
    //picked_option=picked_option-48;
    scanf("%d",&picked_option);
    fgetc(stdin);//get rid of the newline char
    if(picked_option<0 || picked_option>size){
        picked_option=-1;//indicate to exit after freeing the memory allocated by malloc
    }
    return picked_option;
}
//displaying the menu
void displayMenu(MenuItem menu[]){
    for(int i=0; menu[i].name!=NULL ;i++){
        printf("%d) %s\n",i+1,menu[i].name );
    }
}

int calculate_length(MenuItem menu[]){
    int counter=0;
    while(menu[counter].name!=NULL){
        counter++;
    }
    return counter;
}

link* print_scenario(link* list, const char* dummy_char){
    list_print(list,stdout);
    return list;
}

link* load_list(FILE* file){
    //getting the size of the file
    link* head=NULL;
    int file_size = get_file_size(file);
    int readen_bytes = 0;
    while(readen_bytes<file_size){
        virus* virus = readVirus(file);
        head=list_append(head,virus);
        readen_bytes+=18+virus->SigSize;
    }
    return head;
}

link* load_scenario(link* link,const char* dummy_char){
    char* filename=NULL;
    FILE* file;
    printf("Please provide filename for the signature file:\n");
    scanf("%ms",&filename);
    //fgets(filename, MAX_FILENAME_LENGTH, stdin);
    file = fopen(filename,"rb");
    free(filename);
    if(file==NULL){ // if a file can't be open
        fprintf(stderr,"Error in openning filename : %s\n",filename);
        exit(EXIT_FAILURE);
    }
    struct link *head;
    head = load_list(file);
    fclose(file);
    return head;
}

link* quit(link* list,const char* dummy_char){
    list_free(list);
    exit(EXIT_SUCCESS);
    return NULL;
}

link* ItemAt(link* node, int index){
    if(index==0){
        return node;
    }
    else{
        return ItemAt(node->nextVirus,index-1);
    }
}

int get_list_size(link* node){
    if(node==NULL){
        return 0;
    }
    else{
        return get_list_size(node->nextVirus)+1;
    }
}

int compare_virus_sig(char* buffer, unsigned short rest_of_buffer, virus* virus){
    int result=-1;
    if(rest_of_buffer>=virus->SigSize){
        result = memcmp(buffer,virus->sig,virus->SigSize);
    }
    return result;
}

void detect_virus(char *buffer, unsigned int size, link *virus_list){
    for(int offset=0;offset<size;offset++){
        for(int i=0;i<get_list_size(virus_list);i++){
            virus* virus = NULL;
            virus = ItemAt(virus_list,i)->vir;
            if(compare_virus_sig(buffer+offset,size-offset,virus)==0){
                printf("Starting byte: %d\n",offset);
                printf("Virus name: %s\n", virus->virusName);
                printf("Virus size: %d\n\n", virus->SigSize);
            }
        }
    }

}

link* detect_virus_scenario(link* sig_list, const char* filename){
    unsigned int file_size;
    FILE* file;
    file=openFile(filename,"rb");
    file_size = get_file_size(file);
    char* buffer =NULL;
    buffer =malloc(file_size);
    fread(buffer,1,file_size,file);//reading the whole file
    fclose(file);
    detect_virus(buffer,file_size,sig_list);
    free(buffer);
    return sig_list;
}

//my change: from char* filename as argument to: FILE* suspected_file
void kill_virus(FILE* suspected_file, int signitureOffset, int signitureSize){
    fseek(suspected_file, signitureOffset,SEEK_SET);
    printf("starting byte: %ld\n", ftell(suspected_file));
    int nop_val = NOP;
    for(int i=0;i<signitureSize;i++) {
        fwrite(&nop_val, 1, 1, suspected_file);
        fseek(suspected_file,1, SEEK_CUR);
    }

}

link* fix_file_scenario(link* dummy_list,const char* filename){
    unsigned short byte_location;
    unsigned short signature_size;
    FILE* file;
    file=openFile(filename,"r+");
    printf("Please enter the starting byte location in the suspected file and the signature size of the virus:\n");
    scanf("%hd %hd",&byte_location,&signature_size);
    kill_virus(file, byte_location,signature_size);
    fclose(file);
    return dummy_list;
}

int main(int argc, char const *argv[]) {
    char picked_option;
    link* list=NULL;
    const char* suspected_file_name;
    FILE* suspected_file=NULL;
    MenuItem menu[] = { { "Load signatures", load_scenario },
                        { "Print signature", print_scenario },
                        {"Detect viruses",detect_virus_scenario },
                        {"Fix file", fix_file_scenario},
                        { "Quit", quit }, { NULL, NULL } };

    if(argc>1){
        if(argv[1] != NULL) {
            suspected_file_name = argv[1];
        }
        suspected_file=fopen(suspected_file_name,"rb");
        if(suspected_file==NULL){ // if a file can't be open
            fprintf(stderr,"Error in openning filename : %s\n",argv[1]);
            exit(EXIT_FAILURE);
        }
        fclose(suspected_file);
    }
    int array_length = calculate_length(menu);// without the null option
    while(1){
        displayMenu(menu);
        picked_option=get_input_and_check_bounds(array_length)-1;
        if(picked_option==-1){//handle invalid argument
            exit(EXIT_SUCCESS);
        }
        else{
            list = menu[picked_option].fun(list,suspected_file_name);
        }
    }
    return 0;
}
