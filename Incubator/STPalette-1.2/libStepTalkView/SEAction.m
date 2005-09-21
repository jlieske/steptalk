/* All Rights reserved */

#include "SEAction.h"

@implementation SEAction

- (void) forwardInvocation: (NSInvocation*) anInvocation
{
	NSLog (@"invocation : %@", NSStringFromSelector([anInvocation selector]));

	NSString* methodSignature = NSStringFromSelector([anInvocation selector]);

	NSMutableDictionary* arguments = [NSMutableDictionary new];
	int nbArgs = [[anInvocation methodSignature]  numberOfArguments];

	StepTalkMethod* method = [methods objectForKey: methodSignature];

	if (method == nil) // not found in the StepTalk class ...
	{
		NSLog (@"not in the class");
		NSString* ivar = [self findOutlet: methodSignature];
		NSLog (@"ivar: %@", ivar);
		if (ivar != nil)
		{
			id obj;
			if (nbArgs == 3)
			{
				[anInvocation getArgument: &obj atIndex: 2];
				[self setIVar: obj withName: ivar];
			}
		}
		else
		{
			// ... and not an ivar...

			// we call the superclass
			[superClass forwardInvocation: anInvocation];
		}
	}
	else
	{
		int i;
		for (i=2; i< nbArgs; i++)
		{
			id arg;
			[anInvocation getArgument: &arg atIndex: i];

			id argName = [method argumentAtIndex: i-2];

			NSLog (@"arg(%d):<%@>=><%@>", i, argName, arg);
			[arguments setObject: arg forKey: argName];
		}
			
		[self executeMethod: NSStringFromSelector([anInvocation selector]) withArguments: arguments];
	}
}

- (NSMethodSignature*) methodSignatureForSelector: (SEL) aSelector
{
	return STConstructMethodSignatureForSelector (aSelector);
}

- (BOOL) respondsToSelector: (SEL) selector
{
}

@end

