#include <stdio.h>
#include <unistd.h>
#include <elf.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>

#define buffer_length 100

/*Global variables*/
int debug = 0;
int currentFD=-1;
char* currentFilenameOpen="";
void* map_start; /* will point to the start of the memory mapped file */
struct stat fd_stat; /* this is needed to  the size of the file */
Elf32_Ehdr *header; /* this will point to the header structure */
typedef struct {
  char *name;
  void (*fun)();
}fun_desc;

/*typedef struct {
    uint32_t   sh_name;
    uint32_t   sh_type;
    uint32_t   sh_flags;
    Elf32_Addr sh_addr;
    Elf32_Off  sh_offset;
    uint32_t   sh_size;
    uint32_t   sh_link;
    uint32_t   sh_info;
    uint32_t   sh_addralign;
    uint32_t   sh_entsize;
} Elf32_Shdr;*/

int LoadFile(){
    char filename[buffer_length];
    int fd;
    fscanf(stdin, "%s",filename);
    if((fd = open(filename, O_RDWR)) < 0) {
      perror("error in open");
      exit(EXIT_FAILURE);
   }
    if( fstat(fd, &fd_stat) != 0 ) {
      perror("stat failed");
      exit(EXIT_FAILURE);
   }
    if ((map_start = mmap(0, fd_stat.st_size, PROT_READ | PROT_WRITE , MAP_SHARED, fd, 0)) == MAP_FAILED ) {
      perror("mmap failed");
      exit(EXIT_FAILURE);
   }
   if(currentFD!=-1){close(currentFD);}
    currentFD=fd;
	strcpy(currentFilenameOpen,filename);
    return currentFD;
}

/*checks if the file in ELF*/
int isELFfile(Elf32_Ehdr* header){
    if(strncmp(header->e_ident,ELFMAG, 4)==0){return 1;}return 0;
}

/*convert Data constant to strings*/
char* dataType(Elf32_Ehdr* header){
    switch (header->e_ident[5])
    {
    case ELFDATANONE:
        return "invalid data encoding";
        break;
    case ELFDATA2LSB:
        return "2's complement, little endian";
        break;
    case ELFDATA2MSB:
        return "2's complement, big endian";
        break;
    default:
        return "NO DATA";
        break;
    }
}

void examineFile(){
    if(LoadFile()==-1){exit(EXIT_FAILURE);}
    header = (Elf32_Ehdr *) map_start;
    if(isELFfile(header)){
    printf("Magic Numbers: \t\t %X %X %X\n", header->e_ident[EI_MAG0],header->e_ident[EI_MAG1],header->e_ident[EI_MAG2]);
    printf("Data:\t\t %s\n",  dataType(header));
    printf("Enty point address:\t\t 0x%x\n",  header->e_entry);
    printf("Start of section headers:\t\t %d (bytes into file)\n",  header->e_shoff);
    printf("Number of section headers:\t\t %d\n",  header->e_shnum);
    printf("Size of section header:\t\t %d (bytes)\n",  header->e_shentsize);
    printf("Start of program headers:\t\t %d (bytes into file)\n",  header->e_phoff);
    printf("Number of program headers:\t\t %d\n",  header->e_phnum);
    printf("Size of program header:\t\t %d (bytes)\n",  header->e_phentsize);
   }
   else{printf("This is not ELF file\n");
     munmap(map_start, fd_stat.st_size); 
     close(currentFD); 
     currentFD=-1;
	 //currentFilenameOpen="";
     }
}
/*prints out all the sections*/
void printSectionTable(){
    if(currentFD!=-1){
    	Elf32_Shdr* sections_table= map_start+ header->e_shoff;                                            
    	Elf32_Shdr* string_table_entry = sections_table + (header->e_shstrndx * header->e_shentsize);
		if(debug){
			fprintf(stderr,"section table address: %p",sections_table);
			fprintf(stderr,"string table entry: %p",string_table_entry);
		}
    	for (size_t i = 0; i < header->e_shnum; i++)
    	{
    		Elf32_Shdr* entry = sections_table + (i* header->e_shentsize);
        	char* name = map_start + string_table_entry->sh_offset + entry->sh_name;
        	printSectionEntry(i,name,entry);
    	}
  	}
  	else{perror("There is no any file open");}
}

void printSectionEntry(int index,char* name ,Elf32_Shdr* section){
    //[index] section_name section_address section_offset section_size  section_type
    printf("[%d] %s %X %d %d %d",index, name ,section->sh_addr,section->sh_offset, section->sh_size, section->sh_type);

}

/*active debug mode*/
void toggleDebugMode () {
  if (debug == 0) {
    printf("Debug flag now on\n");
    debug = 1;
  }
  else {
    printf("Debug flag now off\n");
    debug = 0;
  }
}

void quit () {
    if (debug) { printf("quitting..\n");}
    exit(EXIT_SUCCESS);
}

void displayMenu (fun_desc menu[]){
	//if(currentFilenameOpen!=""){fprintf(stdout,"Current File Open: %s\n",currentFilenameOpen);}
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
  scanf("%d", &op);
  if (op >= 0 && op < bounds){
    fprintf(stdout, "Within bounds\n" );
    return op;
  }
  else{
    fprintf(stdout, "Not within bounds\n" );
    return -1;
  }
}

int main(int argc, char **argv){
  fun_desc menu[] = { { "Toggle Debug Mode", toggleDebugMode }, {"Examine ELF File",examineFile},{"Print Section Names",printSectionTable},
                                { "Quit", quit } ,{ NULL, NULL } };
  size_t index=0;
  while ( menu[index].name != NULL){index = index +1; }
  while (1) {
    displayMenu(menu);
    int option = getUserInput (index);
    if (option != -1) { menu[option].fun(); }
    printf("\n");
  }
return 0;
}
