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
int currentFD=-1;
char* currentFilenameOpen=NULL;
void* map_start; /* will point to the start of the memory mapped file */
struct stat fd_stat; /* this is needed to  the size of the file */
Elf32_Ehdr *header; /* this will point to the header structure */

/*function decleration*/
int LoadFile(char*);
int isELFfile(Elf32_Ehdr* );
void examineFile(char*);
void printProgramHeaders();
void printProgramHeader(Elf32_Phdr* );
char* convertType(int);


int LoadFile(char* filename){
    int fd;
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

void examineFile(char* filename){
    if(LoadFile(filename)==-1){exit(EXIT_FAILURE);}
    header = (Elf32_Ehdr *) map_start;
    if(isELFfile(header)){
        printProgramHeaders();
   }
   else{printf("This is not ELF file\n");
     munmap(map_start, fd_stat.st_size); 
     close(currentFD); 
     currentFD=-1;
     currentFilenameOpen=NULL;
     }
}
/*prints out all the sections*/
void printProgramHeaders(){
    if(currentFD!=-1){
        //int section_table_offset=header->e_shoff;
    	Elf32_Phdr* program_header= map_start+header->e_phoff;
        printf("      Type      Offset  VirtAddr  PhysAddr        FileSiz       MemSiz   Flg     Align\n");   
    	for (size_t i = 0; i < header->e_phnum; i++)
    	{
    		Elf32_Phdr* entry = map_start+header->e_phoff+(i* header->e_phentsize);
        	printProgramHeader(entry);
    	}
  	}
  	else{perror("No file is currently open\n");}
}

/*prints out one entry of section*/
void printProgramHeader(Elf32_Phdr* entry){
    printf("%12s\t%#06x\t%#06x\t%#10.08x\t%#10.08x\t%#4.05x\t%#4.03x\t%#6.03x\n",convertType(entry->p_type),entry->p_offset,entry->p_vaddr,entry->p_paddr,entry->p_filesz,entry->p_memsz,entry->p_flags,entry->p_align);
}

char* convertType(int type){
    switch (type)
    {
    case PT_NULL: return "NULL";
    case PT_LOAD: return "LOAD";
    case PT_DYNAMIC: return "DYNAMIC";
    case PT_INTERP: return "INTERP";
    case PT_NOTE: return "NOTE";
    case PT_SHLIB: return "SHLIB";
    case PT_PHDR: return "PHDR";
    case PT_TLS: return "TLS";
    case PT_NUM: return "NUM";
    case PT_GNU_EH_FRAME: return "GNU_EH_FRAME";
    case PT_GNU_STACK: return "GNU_STACK";
    case PT_GNU_RELRO: return "GNU_RELRO";
    case PT_SUNWBSS: return "SUNWBSS";
    case PT_SUNWSTACK: return "SUNWSTACK";
    case PT_HIOS: return "HIOS";
    case PT_LOPROC: return "LOPROC";
    case PT_HIPROC: return "HIPROC"; 
    default:return "Unknown";
        break;
    }
}
int main(int argc, char **argv){
    if(argc==2){
        examineFile(argv[1]);
    }


return 0;
}
