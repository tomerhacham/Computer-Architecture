#include "util.h"

/*system call definition*/
#define SYS_EXIT 1
#define SYS_READ 3
#define SYS_WRITE 4
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_LSEEK 19
#define SYS_GETDENTS 141

#define SEEK_SET 0

/* bitmasks for mods and access modes*/
#define O_RDONLY 0
#define O_WRONLY 1
#define O_RDRW 2
#define O_CREATE 64
#define O_RWX 0777

/*file descriptor definition*/
#define STDIN 0
#define STDOUT 1
#define STDERR 2

/*DT definition (from dirent.h)*/
# define DT_UNKNOWN	0
# define DT_FIFO	1
# define DT_CHR		2
# define DT_DIR		4
# define DT_BLK		6
# define DT_REG		8
# define DT_LNK		10
# define DT_SOCK	12
# define DT_WHT		14

#define BUFFER_SIZE 8192


extern int system_call(int syscall, int arg1, int arg2, int arg3);

typedef struct linux_dirent {
   unsigned long  ino;        /* Inode number */
   unsigned long  offset;     /* Offset to next linux_dirent */
   unsigned short len;        /* Length of this linux_dirent */
   char           name[];     /* Filename (null-terminated) */
}linux_dirent;

/*convert type of dirent to string*/
char* getType(char type){
  char* string_type;
  if(type==DT_REG)
    string_type="reguler";
  else if(type==DT_DIR)
    string_type="directory";
  else if(type==DT_FIFO)
    string_type="FIFO";
  else if(type==DT_SOCK)
    string_type="socket";
  else if(type==DT_LNK)
    string_type="symbolic link";
  else if(type==DT_BLK)
    string_type="block device";
  else if(type==DT_CHR)
    string_type="char device";
  else if(type==DT_UNKNOWN)
    string_type="unknown";
  else
    string_type="???";
  return string_type;
}

/*convert system call intt value to string*/
char* getSystemCall(int syscall){
  char* string_type;
  if(syscall==SYS_READ)
    string_type="SYS_READ";
  else if(syscall==SYS_OPEN)
    string_type="SYS_OPEN";
  else if(syscall==SYS_WRITE)
    string_type="SYS_WRITE";
  else if(syscall==SYS_EXIT)
    string_type="SYS_EXIT";
  else if(syscall==SYS_GETDENTS)
    string_type="SYS_GETDENTS";
  else if(syscall==SYS_CLOSE)
    string_type="SYS_CLOSE";
  else if(syscall==SYS_LSEEK)
    string_type="SYS_LSEEK";
  else
    string_type="???";
  return string_type;
}

/*fucntion which will print error message to output file descriptor
param output - file descriptor
param errorMessage - string of the error message
*/
void errorHandler(int output,char* errorMessage){
  system_call(SYS_WRITE,output,errorMessage, strlen(errorMessage));
  system_call(SYS_EXIT,0x55,0,0);
}

/*the function will print the name of the file and the length
param file - pointer to the linux_dirent file
*/
void printDebug_file(linux_dirent* file){
  system_call(SYS_WRITE,STDERR,"name: ",strlen("name: "));
  system_call(SYS_WRITE,STDERR,file->name,strlen(file->name));
  system_call(SYS_WRITE,STDERR,"\t",1);
  system_call(SYS_WRITE,STDERR,"length: ",strlen("length: "));
  system_call(SYS_WRITE,STDERR,itoa(file->len),strlen(itoa(file->len)));
  system_call(SYS_WRITE,STDERR, "\n\n", 2);
}

/*the function will print the system call int value and the
 return value that has been returned from the kernel*/
void printDebug_sys_call(int sys_call, int return_value){
  system_call(SYS_WRITE,STDERR,"system call: ",strlen("system call: "));
  system_call(SYS_WRITE,STDERR,getSystemCall(sys_call),strlen(getSystemCall(sys_call)));
  system_call(SYS_WRITE,STDERR,"\t",1);
  system_call(SYS_WRITE,STDERR,"return value: ",strlen("return value: "));
  system_call(SYS_WRITE,STDERR,itoa(return_value),strlen(itoa(return_value)));
  system_call(SYS_WRITE,STDERR, "\n", 1);
}

/*fucntion which will print the file name
param output_fd - file descriptor
param file - pointer to the linux_dirent file
param debug_flag - indicate if the debug mode is on
returns- the length of the file that has been printed
*/
int printFile(int output_fd,linux_dirent* file,int debug_flag, int prefix_flag, char type){
  int return_val1=1;
  int return_val2=1;
  return_val1=system_call(SYS_WRITE, output_fd, file->name, strlen(file->name));
  if(prefix_flag){
      system_call(SYS_WRITE,output_fd,"\t",1);
      return_val2=system_call(SYS_WRITE, output_fd, getType(type) ,strlen(getType(type)));
  }
  system_call(SYS_WRITE, output_fd, "\n", 1);
  if(return_val1<=0 || return_val2<=0){errorHandler(output_fd,"Error in writing to STDOUT\n");}
  if(debug_flag){
    printDebug_sys_call(SYS_WRITE,return_val1);
    if(prefix_flag){printDebug_sys_call(SYS_WRITE,return_val2);}
    printDebug_file(file);}
  return file->len;
}

int main (int argc , char* argv[], char* envp[])
{
  int output= STDOUT;
  int fd,debug_flag,prefix_flag,i,valid_argument,dirLength;
  char buffer[BUFFER_SIZE];
  linux_dirent* file;
  const char* prefix;

  debug_flag=0;
  prefix_flag=0;
  /*parsing arguments*/
  for(i=1;i<argc;i++){
    valid_argument=0;
    if( (strcmp("-D",argv[i])==0)){
      valid_argument=1;
      debug_flag=1;
    }
    if( strncmp("-p",argv[i],2*sizeof(char))==0){
      valid_argument=1;
      prefix_flag=1;
      prefix=argv[i]+2*sizeof(char);
  }

    if(!valid_argument){
      errorHandler(output,"Invalid argument given\n");
    }
  }

  fd=system_call(SYS_OPEN,".",O_RDONLY,O_RWX);  /*get file descriptor of the directory*/
  if(debug_flag){printDebug_sys_call(SYS_OPEN,fd);}
  if(fd<=0){errorHandler(output,"Error in opening directory\n");}
  dirLength=system_call(SYS_GETDENTS,fd,buffer,BUFFER_SIZE); /*get buffer of the struct of the files in the directory*/
  if(debug_flag){printDebug_sys_call(SYS_GETDENTS,dirLength);}
  if(dirLength<0){errorHandler(output,"Error in getdents system call\n");}

  i=0;
  while(i<dirLength){
    file=(linux_dirent*)(buffer+i); /* load the next file by the struct*/
    char type = *(buffer + i + file->len - 1);
    if(strcmp(file->name,".")!=0 && strcmp(file->name,"..")!=0 ){ /* discarding prints of the root and the prev directory file descriptor*/
      if(prefix_flag && strncmp(file->name,prefix, strlen(prefix))==0){
        printFile(output,file,debug_flag,prefix_flag,type);
      }
      else if(!prefix_flag){
        printFile(output,file,debug_flag,prefix_flag,type);
      }
    }
    i=i+file->len;
  }
  return 0;
}
