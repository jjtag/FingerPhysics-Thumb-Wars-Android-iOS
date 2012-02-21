#ifndef __log_h__
#define __log_h__

#include "android/log.h"
#include "config.h"

#ifdef ENABLE_LOG
#define _LOG(args...) __android_log_print(ANDROID_LOG_INFO, "CTR", ##args)
#else
#define _LOG(args...)
#endif

#endif // __log_h__
