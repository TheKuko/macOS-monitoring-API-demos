//
//  Tools.mm
//  
//
//  Created by Jozef on 18/05/2020.
//

#include <chrono>
#include <Foundation/Foundation.h>
#include <Kernel/kern/cs_blobs.h>
#include <iomanip>
#include <mach/mach_time.h>
#include <stdexcept>
#include <sstream>
#include <string>
#include <sys/fcntl.h>
#include "Tools.hpp"

// MARK: - Custom Casts
@implementation NSString (alternativeConstructorsCpp)

+(NSString*)stringFromCppString:(std::string const &)cppString
{
    return [[NSString alloc] initWithCString:cppString.c_str() encoding:NSStringEncodingConversionAllowLossy];
}

-(std::string)cppString
{
    return std::string([self cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
}

@end

std::string to_string(const NSString *nsString)
{
    return std::string([nsString cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
}


// https://gist.github.com/leiless/de908154e4c1952186069fe330680b70
uint64_t mach_time_to_msecs(uint64_t mach_time)
{
    mach_timebase_info_data_t tb;
    kern_return_t e = mach_timebase_info(&tb);
    if (e != KERN_SUCCESS)
        throw std::invalid_argument("Could not convert mach time to msecs!");
    return (mach_time * tb.numer) / (tb.denom * NSEC_PER_MSEC);
}

uint64_t msecs_to_mach_time(uint64_t ms)
{
    mach_timebase_info_data_t tb;
    kern_return_t e = mach_timebase_info(&tb);
    if (e != KERN_SUCCESS)
        throw std::invalid_argument("Could not convert mach time to msecs!");
    return (ms * tb.denom * NSEC_PER_MSEC) / tb.numer;
}

//https://stackoverflow.com/questions/17223096/outputting-date-and-time-in-c-using-stdchrono
std::string convert_to_time_and_date(std::chrono::time_point<std::chrono::system_clock> time)
{
    auto in_time_t = std::chrono::system_clock::to_time_t(time);

    std::stringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y%m%d%H%M%S");
    return ss.str();
}

std::string current_time_and_date()
{
    auto now = std::chrono::system_clock::now();
    return convert_to_time_and_date(now);
}


#define longestesfflaglen    11
static struct {
    char name[longestesfflaglen + 1];
    uint32_t flag;
} const esmapping[] = {
    { "FREAD",          FREAD },
    { "FWRITE",         FWRITE },
    { "FAPPEND",        FAPPEND },
    { "FASYNC",         FASYNC },
    { "FFSYNC",         FFSYNC },
    { "FFDSYNC",        FFDSYNC },
    { "FNONBLOCK",      FNONBLOCK },
    { "FNDELAY",        FNDELAY },
    { "O_NDELAY",       O_NDELAY },
    { "O_SHLOCK",       O_SHLOCK },
    { "O_EXLOCK",       O_EXLOCK },
    { "O_NOFOLLOW",     O_NOFOLLOW },
    { "O_CREAT",        O_CREAT },
    { "O_TRUNC",        O_TRUNC },
    { "O_EXCL",         O_EXCL },
    { "O_DIRECTORY",    O_DIRECTORY },
    { "O_SYMLINK",      O_SYMLINK },
};
#define nesmappings    (sizeof(esmapping) / sizeof(esmapping[0]))

// Based on freebsd/lib/libc/gen/strtofflags.c
char *esfflagstostr(uint32_t flags)
{
    char *string;
    const char *sp;
    char *dp;
    uint32_t setflags;
    u_int i;

    if ((string = (char *)malloc(nesmappings * (longestesfflaglen + 1))) == NULL)
        return (NULL);

    setflags = flags;
    dp = string;
    for (i = 0; i < nesmappings; i++) {
        if (setflags & esmapping[i].flag) {
            if (dp > string)
                *dp++ = ',';
            for (sp = esmapping[i].name; *sp; *dp++ = *sp++) ;
            setflags &= ~esmapping[i].flag;
        }
    }
    *dp = '\0';
    return (string);
}


#define longestcsflaglen    25
static struct {
    char name[longestcsflaglen + 1];
    uint32_t flag;
} const csmapping[] = {
    { "CS_VALID",                   CS_VALID },
    { "CS_ADHOC",                   CS_ADHOC },
    { "CS_GET_TASK_ALLOW",          CS_GET_TASK_ALLOW },
    { "CS_INSTALLER",               CS_INSTALLER },
    { "CS_FORCED_LV",               CS_FORCED_LV },
    { "CS_INVALID_ALLOWED",         CS_INVALID_ALLOWED },
    { "CS_HARD",                    CS_HARD },
    { "CS_KILL",                    CS_KILL },
    { "CS_CHECK_EXPIRATION",        CS_CHECK_EXPIRATION },
    { "CS_RESTRICT",                CS_RESTRICT },
    { "CS_ENFORCEMENT",             CS_ENFORCEMENT },
    { "CS_REQUIRE_LV",              CS_REQUIRE_LV },
    { "CS_ENTITLEMENTS_VALIDATED",  CS_ENTITLEMENTS_VALIDATED },
    { "CS_NVRAM_UNRESTRICTED",      CS_NVRAM_UNRESTRICTED },
    { "CS_RUNTIME",                 CS_RUNTIME },
    { "CS_EXEC_SET_HARD",           CS_EXEC_SET_HARD },
    { "CS_EXEC_SET_KILL",           CS_EXEC_SET_KILL },
    { "CS_EXEC_SET_ENFORCEMENT",    CS_EXEC_SET_ENFORCEMENT },
    { "CS_EXEC_INHERIT_SIP",        CS_EXEC_INHERIT_SIP },
    { "CS_KILLED",                  CS_KILLED },
    { "CS_DYLD_PLATFORM",           CS_DYLD_PLATFORM },
    { "CS_PLATFORM_BINARY",         CS_PLATFORM_BINARY },
    { "CS_PLATFORM_PATH",           CS_PLATFORM_PATH },
    { "CS_DEBUGGED",                CS_DEBUGGED },
    { "CS_SIGNED",                  CS_SIGNED },
    { "CS_DEV_CODE",                CS_DEV_CODE },
    { "CS_DATAVAULT_CONTROLLER",    CS_DATAVAULT_CONTROLLER },
};
#define ncsmappings    (sizeof(csmapping) / sizeof(csmapping[0]))

char *csflagstostr(uint32_t flags)
{
    char *string;
    const char *sp;
    char *dp;
    uint32_t setflags;
    u_int i;

    if ((string = (char *)malloc(ncsmappings * (longestcsflaglen + 1))) == NULL)
        return (NULL);

    setflags = flags;
    dp = string;
    for (i = 0; i < ncsmappings; i++) {
        if (setflags & csmapping[i].flag) {
            if (dp > string)
                *dp++ = ',';
            for (sp = csmapping[i].name; *sp; *dp++ = *sp++) ;
            setflags &= ~csmapping[i].flag;
        }
    }
    *dp = '\0';
    return (string);
}


static struct {
    std::string name;
    uint32_t flag;
} const famapping[] = {
    {"F_OK",        F_OK},
    {"X_OK",        X_OK},
    {"R_OK",        R_OK},
    {"_READ_OK",    _READ_OK},
    {"_WRITE_OK",   _WRITE_OK},
    {"_EXECUTE_OK", _EXECUTE_OK},
    {"_DELETE_OK",  _DELETE_OK},
    {"_APPEND_OK",  _APPEND_OK},
    {"_RMFILE_OK",  _RMFILE_OK},
    {"_RATTR_OK",   _RATTR_OK},
    {"_WATTR_OK",   _WATTR_OK},
    {"_REXT_OK",    _REXT_OK},
    {"_WEXT_OK",    _WEXT_OK},
    {"_RPERM_OK",   _RPERM_OK},
    {"_WPERM_OK",   _WPERM_OK},
    {"_CHOWN_OK",   _CHOWN_OK},
};

std::string faflagstostr(uint32_t flags)
{
    if (flags == F_OK)
        return "F_OK";

    std::string string;

    for (unsigned long i=0; i < sizeof(famapping) || !flags; ++i) {
        if (famapping[i].flag & flags) {
            if (!string.empty())
                string += ",";

            string += famapping[i].name;
            flags &= ~famapping[i].flag;
        }
    }

    return string;
}
