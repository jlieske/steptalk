/* All Rights reserved */

#include "StepTalkProxy.h"

@implementation StepTalkProxy

- (id) init
{
//	if (self = [super init])
	{
		NSLog (@"proxy init...");
		STClass = [StepTalkClass new];
	}
	return self;
}

- (void) dealloc
{
	[STClass release];
	[super dealloc];
}

- (void) forwardInvocation: (NSInvocation*) anInvocation
{
	NSLog (@"STProxy: forwardInvocation(%@)", anInvocation);
	NSLog (@"invocation : %@", NSStringFromSelector([anInvocation selector]));
	[STClass executeMethod: NSStringFromSelector([anInvocation selector])];
}

- (NSMethodSignature*) methodSignatureForSelector: (SEL) aSelector
{
	return STConstructMethodSignatureForSelector (aSelector);
}

@end

