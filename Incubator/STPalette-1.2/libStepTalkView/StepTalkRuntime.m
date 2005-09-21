/* All Rights reserved */

#include "StepTalkRuntime.h"

static StepTalkRuntime* STRuntime;

@implementation StepTalkRuntime

- (void) encodeWithCoder: (NSCoder*) coder
{
	//[super encodeWithCoder: coder];
	[coder encodeObject: classes];
}

- (id) initWithCoder: (NSCoder*) coder
{
	//if (self = [super initWithCoder: coder]) 
	{
		ASSIGN (classes, [coder decodeObject]);
	}
	return self;
}

+ (id) defaultRuntime
{
	if (STRuntime == nil)
	{
		STRuntime = [StepTalkRuntime new];
	}
	return STRuntime;
}

- (id) init
{
	if (self = [super init])
	{
		classes = [NSMutableDictionary new];
	}
	return self;
}

- (void) dealloc
{
	[classes release];
	[super dealloc];
}

- (void) addClass: (StepTalkClass*) aClass
{
	NSLog (@"RUNTIME addClass %@", [aClass name]);
	[classes setObject: aClass forKey: [aClass name]];
}

- (StepTalkClass*) classForName: (NSString*) name
{
	NSLog (@"RUNTIME classForName %@", name);
	id ret = [classes objectForKey: name];
	NSLog (@"==> %@", ret);
	return ret;
}

@end
