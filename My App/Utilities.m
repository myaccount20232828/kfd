#import <Foundation/Foundation.h>
#import <spawn.h>
#import <mach-o/dyld.h>
#import <sys/stat.h>
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
    u32 _buf[2] = {};
    _buf[0] = what;
    _buf[1] = kread32(where+4);
    kwrite((u64)(_kfd), &_buf, where, sizeof(u64));
}

void kwrite64(uint64_t where, uint64_t what) {
    u64 _buf[1] = {};
    _buf[0] = what;
    kwrite((u64)(_kfd), &_buf, where, sizeof(u64));
}

