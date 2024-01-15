#import <Foundation/Foundation.h>
#import <stdio.h>

uint64_t kopen(uint64_t puaf_pages, uint64_t puaf_method, uint64_t kread_method, uint64_t kwrite_method);
void kclose(uint64_t kfd);
void postExploit(void);
uint32_t kread32(uint64_t where);
uint64_t kread64(uint64_t where);
void kwrite32(uint64_t where, uint32_t what);
void kwrite64(uint64_t where, uint64_t what);
uint64_t getProc(pid_t pid);
void kfd_print(char* format, ...);
void testPrint(void);
void enableLog(BOOL enable);
