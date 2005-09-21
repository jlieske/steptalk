/* All Rights reserved */

#ifndef __STMETADATAS_H__
#define __STMETADATAS_H__

#include <AppKit/AppKit.h>
#include <StepTalk/StepTalk.h>

@interface StepTalkMetadatas : NSObject
{
	NSMutableDictionary* tags;
	NSString* documentation;
}
@end

#endif
