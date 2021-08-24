#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TIOAD.h"
#import "TIOADClient.h"
#import "TIOADDefines.h"
#import "TIOADToadImageReader.h"

FOUNDATION_EXPORT double ti_oadVersionNumber;
FOUNDATION_EXPORT const unsigned char ti_oadVersionString[];

