#import <Foundation/Foundation.h>
#import <stdio.h>

uint64_t kopen(uint64_t puaf_pages, uint64_t puaf_method, uint64_t kread_method, uint64_t kwrite_method);
void kclose(uint64_t kfd);
//uint64_t getProc(pid_t pid);
