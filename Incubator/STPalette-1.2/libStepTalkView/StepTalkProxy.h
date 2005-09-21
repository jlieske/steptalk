/* All Rights reserved */

#ifndef __STPROXY_H__
#define __STPROXY_H__

#include <AppKit/AppKit.h>
#include <StepTalk/StepTalk.h>
#include <StepTalkView/StepTalkClass.h>

@interface StepTalkProxy : NSProxy
{
	id STClass;
}
- (id) init;
@end

#endif
