#include "util.h"

#define SYS_EXIT 1
#define SYS_READ 3
#define SYS_WRITE 4
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_LSEEK 19
#define STDOUT 1
#define SEEK_SET 0
#define O_RDRW 2

int main (int argc , char* argv[], char* envp[])
{
  int shira_pos = 657;
  char * name_to_replace;
  char* filename;
  int fd;
  if (argc==3){
    filename=argv[1];
    name_to_replace=argv[2];
    fd=system_call(SYS_OPEN,filename,O_RDRW,0777);
    if(fd<0){
      system_call(SYS_EXIT,0x55);
    }
    system_call(SYS_LSEEK,fd,shira_pos,SEEK_SET);
    system_call(SYS_WRITE,fd,name_to_replace,strlen(name_to_replace));
    system_call(SYS_CLOSE,fd);
  }
  else{
    system_call(SYS_WRITE,STDOUT,"Invalid number of arguments\n",strlen("Invalid number of arguments\n"));
  }
  return 0;
}
