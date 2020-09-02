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
char* currentFilenameOpen=NULL;
void* map_start; /* will point to the start of the memory mapped file */
struct stat fd_stat; /* this is needed to  the size of the file */
Elf32_Ehdr *header; /* this will point to the header structure */
typedef struct {
  char *name;
  void (*fun)();
}fun_desc;

/*function decleration*/
int LoadFile();
int isELFfile(Elf32_Ehdr* );
char* dataType(Elf32_Ehdr* );
char* sectionType(int);
void examineFile();
void printSectionTable();
void printSectionEntry(int ,char*  ,Elf32_Shdr* , int);
void toggleDebugMode();
void quit();
void displayMenu(fun_desc menu[]);
int getUserInput(int);
void printSymbolTable();
Elf32_Shdr* get_table_by_name(char*);

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
	strcpy(&currentFilenameOpen,filename);
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
     currentFilenameOpen=NULL;
     //strcpy(&currentFilenameOpen,"");
     }
}
/*prints out all the sections*/
void printSectionTable(){
    if(currentFD!=-1){
        //int section_table_offset=header->e_shoff;
    	Elf32_Shdr* sections_table= map_start+header->e_shoff;
    	Elf32_Shdr* string_table_entry = map_start+ header->e_shoff+(header->e_shstrndx*header->e_shentsize);
		if(debug){
			fprintf(stderr,"section table address: %p\n",sections_table);
			fprintf(stderr,"string table entry: %p\n",string_table_entry);
            printf("[index] section_name section_address section_offset section_size  section_type  offset(bytes)\n");

        }
		else{		printf("[index] section_name section_address section_offset section_size  section_type\n");
        }
    	for (size_t i = 0; i < header->e_shnum; i++)
    	{
    		Elf32_Shdr* entry = map_start+header->e_shoff+(i* header->e_shentsize);
        	char* name = map_start + string_table_entry->sh_offset + entry->sh_name;
        	printSectionEntry(i,name,entry,header->e_shoff+(i* header->e_shentsize));
    	}
  	}
  	else{perror("There is no any file open");}
}

/*prints out one entry of section*/
void printSectionEntry(int index,char* name ,Elf32_Shdr* section,int offset){
    if(debug){
        printf("[%#02d]\t%20.20s\t%#06x\t%#06d\t%#10.06d\t%13.20s\t%#10d\n",index, name ,section->sh_addr,section->sh_offset, section->sh_size, sectionType(section->sh_type),offset );
    }
    else
    {printf("[%#02d]\t%20.20s\t%#06x\t%#06d\t%#10.06d\t%13.20s\n",index, name ,section->sh_addr,section->sh_offset, section->sh_size, sectionType(section->sh_type) );}
}

/*return pointer to the relevent table entry*/
Elf32_Shdr* get_table_by_name(char* _name){
    if(currentFD!=-1){
        Elf32_Shdr* sections_table= map_start+header->e_shoff;
        Elf32_Shdr* string_table_entry = map_start+ header->e_shoff+(header->e_shstrndx*header->e_shentsize);
        for (size_t i = 0; i < header->e_shnum; i++)
        {
            Elf32_Shdr* entry = map_start+header->e_shoff+(i* header->e_shentsize);
            char* name = map_start + string_table_entry->sh_offset + entry->sh_name;
            if(strcmp(_name, name)==0){return entry;}
            //printSectionEntry(i,name,entry,header->e_shoff+(i* header->e_shentsize));
        }
    }
    else{perror("There is no any file open");}
    return NULL;
}

/*prints out the synbol table in the ELF*/
void printSymbolTable(){
    Elf32_Shdr* symbol_table_entry = get_table_by_name(".symtab");
    Elf32_Shdr* strtab = get_table_by_name(".strtab");
    Elf32_Shdr* shstrtab = get_table_by_name(".shstrtab");
    if(symbol_table_entry!=NULL){
        Elf32_Sym* symbol_table = map_start+symbol_table_entry->sh_offset;
        int num_of_entries = symbol_table_entry->sh_size/sizeof(Elf32_Sym);
        printf("[index] value section_index\tsection_name\tsymbol_name\n");
        for (size_t i = 0; i < num_of_entries; i++)
        {
            Elf32_Sym* entry = map_start+symbol_table_entry->sh_offset+(i*sizeof(Elf32_Sym));
            char* section_name;
            if(entry->st_shndx==0xFFF1){section_name = "ABS";}
            else if(entry->st_shndx==0x0){section_name = "UNK";}
            else{
                Elf32_Shdr* section_entry = map_start+header->e_shoff+(entry->st_shndx* header->e_shentsize);
                section_name = map_start + shstrtab->sh_offset + section_entry->sh_name;
            }
            char* symbol_name = map_start+ strtab->sh_offset+entry->st_name;

            printf("[%#02d]\t%08d\t%#05d\t%13.20s\t\%20.30s\n",i,entry->st_value,entry->st_shndx,section_name,symbol_name);
        }
    }
    else{
        perror("Could not find symbol table in the file");
    }
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
	if(currentFilenameOpen!=NULL /*strcmp(currentFilenameOpen,"")!=0*/){
	    fprintf(stdout,"Current File Open: %s\n",&currentFilenameOpen);
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

/*convert section constant type to string*/
char* sectionType(int value) {
    switch (value) {
        case SHT_NULL:return "NULL";
        case SHT_PROGBITS:return "PROGBITS";
        case SHT_SYMTAB:return "SYMTAB";
        case SHT_STRTAB:return "STRTAB";
        case SHT_RELA:return "RELA";
        case SHT_HASH:return "HASH";
        case SHT_DYNAMIC:return "DYNAMIC";
        case SHT_NOTE:return "NOTE";
        case SHT_NOBITS:return "NOBITS";
        case SHT_REL:return "REL";
        case SHT_SHLIB:return "SHLIB";
        case SHT_DYNSYM:return "DYNSYM";
        default:return "Unknown";
    }
}

int main(int argc, char **argv){
  fun_desc menu[] = { { "Toggle Debug Mode", toggleDebugMode }, {"Examine ELF File",examineFile},{"Print Section Names",printSectionTable},
                      {"Print Symbols",printSymbolTable},{ "Quit", quit } ,{ NULL, NULL } };
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
