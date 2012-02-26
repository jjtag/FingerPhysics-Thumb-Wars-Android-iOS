//
//  Debug.h
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

// Debug system
//
// Features:
//
// - Logging of formatted text to stdout
// - Assertion logging with stack trace
// - Exception logging with stack trace
// - Blocking/non-blocking alerts with debug info output and ignore/exit buttons
// - Simple benchmarking
//
// Todo:
//
// - Network logger
// - File logger
//
// Known bugs:
//
// - Alerts on the iPhone freeze if you try to scroll them

// logs and alerts turned on only in debug builds
#ifdef DEBUG 
	#define LOG_MEM 0
	#define LOG_SND 0
#else
	#define LOG_MEM 0
	#define LOG_SND 0
	
	#define NO_ASSERTS
	#define NO_ALERTS
#endif

#define HANDLED_EXCEPTION_EXIT_CODE 100

//#define ALERT_OPENAL_ERRORS
#define ALERT_ASSERTS
#define ALERT_EXCEPTIONS

// assertion macros
#ifdef NO_ASSERTS
	#define ASSERT(COND)
	#define ASSERT_MSG(COND, MSG)
#else
	#define ASSERT(COND) if (!(COND)) logAndShowAssert(@"Assert", __FILE__, __LINE__, __PRETTY_FUNCTION__)
	#define ASSERT_MSG(COND, MSG) if (!(COND)) logAndShowAssert(MSG, __FILE__, __LINE__, __PRETTY_FUNCTION__)
#endif
// logging
#define LOG(MSG) logString(MSG)
#define LOGF(FORMAT, ...) logString(FORMAT_STRING(FORMAT, __VA_ARGS__))
#define LOG_GROUP(GROUP, MSG) { if (LOG_##GROUP != 0) logString(MSG); }
#define LOG_GROUPF(GROUP, FORMAT, ...) { if (LOG_##GROUP != 0) logString(FORMAT_STRING(FORMAT, __VA_ARGS__)); }

// information alerts
#define BLOCKING_INFO_ALERT_TITLED(TITLE, MSG) showBlockingAlert(TITLE, MSG, ALERT_TYPE_INFO)
#define BLOCKING_INFO_ALERT(MSG) showBlockingAlert(@"Info", MSG, ALERT_TYPE_INFO)
#define INFO_ALERT_TITLED(TITLE, MSG) showAlert(TITLE, MSG, ALERT_TYPE_INFO)
#define INFO_ALERT(MSG) showAlert(@"Info", MSG, ALERT_TYPE_INFO)

// alert types
#define ALERT_TYPE_ERROR 0
#define ALERT_TYPE_INFO 1	

// error alerts
#define BLOCKING_ERROR_ALERT_TITLED(TITLE, MSG) showBlockingAlert(TITLE, MSG, ALERT_TYPE_ERROR)
#define BLOCKING_ERROR_ALERT(MSG) showBlockingAlert(@"Error", MSG, ALERT_TYPE_ERROR)
#define ERROR_ALERT_TITLED(TITLE, MSG) showAlert(TITLE, MSG, ALERT_TYPE_ERROR)
#define ERROR_ALERT(MSG) showAlert(@"Error", MSG, ALERT_TYPE_ERROR)
#define LOG_AND_SHOW_EXCEPTION(E) logAndShowException(E)

// can be useful to show current version info
#define COMPILATION_TIMESTAMP FORMAT_STRING(@"%s %s", __DATE__, __TIME__)

// benchmarking helpers
#define BENCHMARK_ITERS 100000

#define START_BENCHMARK(NAME, ITERATIONS, SHOW_ALERT) { NSString* __name = NAME; bool __showAlert = SHOW_ALERT; int __c = ITERATIONS; \
	 double __time1 = CFAbsoluteTimeGetCurrent(); for(int n = 0;n<__c;n++) {
#define END_BENCHMARK } double __time2 = CFAbsoluteTimeGetCurrent(); double __delta = __time2 - __time1; \
	NSString* str = FORMAT_STRING(@"%@: %f ms",__name , (float)((__delta * 1000))); LOG(str); \
	if (__showAlert) BLOCKING_INFO_ALERT_TITLED(@"Benchmark", str); }

#if defined(DEBUG) && TARGET_IPHONE_SIMULATOR
	#define DebugBreak() if(AmIBeingDebugged()) {__asm__("int $3\n" : : );}
	bool AmIBeingDebugged(void);
#else
	#define DebugBreak()
#endif

#ifdef __cplusplus
extern "C" {
#endif	
void logString(NSString* string);
NSString* logAssert(NSString* message, const char* file, int line, const char* func);
NSString* logException(NSException* e);
void showBlockingAlert (NSString* title, NSString* message, int type);
void showAlert(NSString* title, NSString* message, int type);
void logAndShowAssert(NSString* message, const char* file, int line, const char* func);
void logAndShowException(NSException* e);
#ifdef __cplusplus
}
#endif	

void uncaughtExceptionHandler(NSException* e);