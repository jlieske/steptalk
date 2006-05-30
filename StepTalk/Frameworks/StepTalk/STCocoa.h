/**
    STCocoa
    
    Copyright (c) 2002 Free Software Foundation
    
    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL
    
    This file is part of the StepTalk project.
*/

#import <Foundation/Foundation.h>

#import "NSObject+CocoaAdditions.h"
#import "NSUserDefaults+CocoaAdditions.h"

/* Memory Management macros as defined in GNUstep */
#define AUTORELEASE(object) [object autorelease]
#define RELEASE(object) [object release]
#define RETAIN(object) [object retain]
#define ASSIGN(object, value)	({\
id __value = (id)(value); \
id __object = (id)(object); \
if (__value != __object) { \
   if (__value != nil) \
      [__value retain]; \
   object = __value; \
   if (__object != nil) \
      [__object release]; \
}})

/* Debugging functions and macros */
BOOL DebugSet(NSString* level);

#ifdef DEBUG

#define NSDebugLLog(level, format, args...) \
do { if (DebugSet(level) == YES) \
   NSLog(format , ## args); } while (0)

#define NSDebugLog(format, args...) \
do { if (DebugSet(@"dflt") == YES) \
   NSLog(format , ## args); } while (0)

#else

#define NSDebugLLog(level, format, args...)
#define NSDebugLog(format, args...)

#endif // DEBUG

/* Private method in NSMethodSignature */
@interface NSMethodSignature (PrivateMethods)
+ (id) signatureWithObjCTypes: (const char*) objCTypes;
@end
