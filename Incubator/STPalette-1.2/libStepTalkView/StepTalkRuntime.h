/* All Rights reserved */

#ifndef __STRUNTIME_H__
#define __STRUNTIME_H__

#include <AppKit/AppKit.h>
#include <StepTalk/StepTalk.h>

#include "StepTalkClass.h"

@class StepTalkClass;

@interface StepTalkRuntime : NSObject
{
	NSMutableDictionary* classes;
}
+ (id) defaultRuntime;
- (void) addClass: (StepTalkClass*) aClass;
- (StepTalkClass*) classForName: (NSString*) name;
@end

#endif
