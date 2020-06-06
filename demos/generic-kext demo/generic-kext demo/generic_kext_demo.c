//
//  generic_kext_demo.c
//  generic-kext demo
//
//  Created by Jozef on 28/05/2020.
//  Copyright © 2020 Jozef Zuzelka. All rights reserved.
//

#include <sys/systm.h>
#include <mach/mach_types.h>

static const char* g_demoName = "generic-kext";
// Define endpoints
kern_return_t generic_kext_demo_start(kmod_info_t * ki, void *d);
kern_return_t generic_kext_demo_stop(kmod_info_t *ki, void *d);

// The extension has been loaded. Register your callbacks..
kern_return_t generic_kext_demo_start(kmod_info_t * ki, void *d)
{
    printf("(%s) Hello, World!\n", g_demoName);
    return KERN_SUCCESS;
}

// Clean up allocated resources.
kern_return_t generic_kext_demo_stop(kmod_info_t *ki, void *d)
{
    printf("(%s) Goodbye, World!\n", g_demoName);
    return KERN_SUCCESS;
}
