//
//  Debug.m
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Debug.h"
#import "../support/GTMStackTrace.h"
#import "Application.h"
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

#if defined(DEBUG) && TARGET_IPHONE_SIMULATOR 
bool AmIBeingDebugged(void)
// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
	
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
	
    info.kp_proc.p_flag = 0;
	
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
	
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
	
    // Call sysctl.
	
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    ASSERT(junk == 0);
	
    // We're being debugged if the P_TRACED flag is set.
	
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}
#endif

void logString(NSString* string)
{
	printf("%s\r\n", [string UTF8String]);
}

NSString* logAssert(NSString* message, const char* file, int line, const char* func)
{
	// get the stacktrace ignoring 3 latest stack frames
	NSString* trace = GTMStackTrace(3);
	NSString* fullMessage = [NSString stringWithFormat:@"%@ at %s, %d\r\n\r\n", message, file, line, func];
	fullMessage = [fullMessage stringByAppendingString:trace];
	LOG(fullMessage);
	return fullMessage;
}

NSString* logException(NSException* e)
{
	// get the stacktrace ignoring 4 latest stack frames
	NSString* trace = GTMStackTraceFromException(e, 4);
	NSString* fullMessage = [NSString stringWithFormat:@"%@: %@\r\n\r\n", [e name], [e reason]];	
	fullMessage = [fullMessage stringByAppendingString:trace];
	LOG(fullMessage);
	return fullMessage;	
}	
		
void showAlert(NSString* title, NSString* message, int type)
{
	[[Application sharedRootController] showAlertWithTitle:title AndMessage:message OfType:type];
}

void showBlockingAlert(NSString* title, NSString* message, int type)
{
	[[Application sharedRootController] showBlockingAlertWithTitle:title AndMessage:message OfType:type];
}

void logAndShowAssert(NSString* message, const char* file, int line, const char* func)
{
	NSString* title = @"Assertion failed";
	NSString* filens = [NSString stringWithCString:file encoding:NSUTF8StringEncoding];
	NSArray* pathArray = [filens componentsSeparatedByString:@"/"];
	NSString* fullMessage = logAssert(message, [[pathArray objectAtIndex:([pathArray count] - 1)] UTF8String], line, func);
#ifdef ALERT_ASSERTS	
	BLOCKING_ERROR_ALERT_TITLED(title, fullMessage);
#endif
}

void logAndShowException(NSException* e)
{
	NSString* title = @"Exception";
	NSString* fullMessage = logException(e);
#ifdef ALERT_EXCEPTIONS
	BLOCKING_ERROR_ALERT_TITLED(title, fullMessage);	
#endif
}

void uncaughtExceptionHandler(NSException* e)
{
	logException(e);
}