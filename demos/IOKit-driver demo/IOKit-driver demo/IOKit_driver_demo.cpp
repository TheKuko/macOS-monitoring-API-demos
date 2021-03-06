//
//  IOKit_driver_demo.cpp
//  IOKit-driver demo
//
//  Created by Jozef on 24/05/2020.
//  Copyright © 2020 Jozef Zuzelka. All rights reserved.
//
// Sources:
//  https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KEXTConcept/KEXTConceptIOKit/iokit_tutorial.html

#include <IOKit/IOLib.h>
#include "IOKit_driver_demo.hpp"

// This required macro defines the class's constructors, destructors,
// and several other methods I/O Kit requires.
OSDefineMetaClassAndStructors(com_test_driver_IOKit_driver_demo, IOService)

// Define the driver's superclass.
#define super IOService

static const char* g_demoName = "IOKit-driver";
// The first instance method called on each instance of the driver class.
// It's called only once on each instance.
bool com_test_driver_IOKit_driver_demo::init(OSDictionary *dict)
{
    if (!super::init(dict)) {
        IOLog("%s demo: super::init() failed.\n", g_demoName);
        return false;
    }

    IOLog("(%s) Hello, World!\n", g_demoName);
    IOLog("%s demo: Initializing\n", g_demoName);
    return true;
}

// The last method called on any objects.
void com_test_driver_IOKit_driver_demo::free(void)
{
    IOLog("%s demo: Freeing\n", g_demoName);
    super::free();
}

// Called to communicate with hardware to determine wheter there is a match.
// Leave the hardware in a good state  upon return for other probing drivers.
IOService *com_test_driver_IOKit_driver_demo::probe(IOService *provider,
    SInt32 *score)
{
    IOService *result = super::probe(provider, score);
    IOLog("%s demo: Probing...\n", g_demoName);

    bool shouldBlock = true; // I.e., ask user..
    if (shouldBlock) {
        (*score) = INT32_MAX;
        IOLog("%s demo: Blocking with score %d...\n", g_demoName, *score);
        return this;
    }

    // I ain't takin' it!
    return nullptr;
}

// Place for driver to set up its functionality.
// After it's called, the driver can begin routing I/O, publishing nubs, and vending services.
bool com_test_driver_IOKit_driver_demo::start(IOService *provider)
{
    if (!super::start(provider)) {
        IOLog("%s demo: super::start() failed.\n", g_demoName);
        return false;
    }

    IOLog("%s demo: Starting\n", g_demoName);
    return true;
}

// The first method called before the driver is unloaded. Clean up!
void com_test_driver_IOKit_driver_demo::stop(IOService *provider)
{
    IOLog("(%s) Goodbye, World!\n", g_demoName);
    IOLog("%s demo: Stopping\n", g_demoName);
    super::stop(provider);
}
