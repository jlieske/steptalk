/* All Rights reserved */

#include "StepTalkView.h"

@implementation StepTalkView

- (NSImage*) imageForView { return nil; }

- (void) encodeWithCoder: (NSCoder*) coder
{
	[super encodeWithCoder: coder];
	[coder encodeObject: object];
}

- (id) initWithCoder: (NSCoder*) coder
{
	if (self = [super initWithCoder: coder]) 
	{
		ASSIGN (object, [coder decodeObject]);
		[self setOutlets];
	}
	return self;
}

- (id) initWithFrame: (NSRect) frame
{
	self = [super initWithFrame: frame];
	object = [StepTalkObject new];
	[self setTitle: @"ButtonScript"];
	[self setImage: [self imageForView]];
	[self setBordered: YES];
	[self setImagePosition: NSImageAbove];
	[self setTarget: self];
	[self setAction: @selector(execute:)];
	[self setOutlets];
        return self;
}	

- (void) dealloc
{
	[object release];
	[super dealloc];
}

- (void) addIVar: (NSString*) name
{
	[object addIVar: name];
}

- (void) removeIVar: (NSString*) name
{
	[object removeIVar: name];
}

- (void) renameIVar: (id) key to: (id) name
{
	[object renameIVar: key to: name];
}

- (void) setIVar: (id) obj withName: (NSString*) name
{
	[object setIVar: obj withName: name];
}

- (id) ivarWithName: (NSString*) name
{
	return [object ivarWithName: name];
}

- (NSMutableDictionary*) variables { return [object variables]; }
- (NSMutableArray*) variablesArray 
{
	return [object variablesArray];
}

- (void) setOutlets
{
	[object setOutlets];
}

- (NSString*) script { return [object script]; }

- (void) setScript: (NSString*) aScript 
{
	[object setScript: aScript];
}

- (void) execute: (id) sender
{
	[object execute: sender];
}

- (BOOL) respondsToSelector: (SEL) selector
{
	NSString* sel = NSStringFromSelector(selector);
	if ([object findOutlet: sel] != nil)
	{
		return YES;
	}
	BOOL ret = [[self class] instancesRespondToSelector: selector];
	NSLog (@"respondsToSelector (%@) -> (%d)", sel, ret);
	return ret;
}

- (id) performSelector: (SEL) selector withObject: (id) obj
{
	NSString* sel = NSStringFromSelector(selector);
	NSString* ivar = [object findOutlet: sel];
	if (ivar != nil)
	{
		[self setIVar: obj withName: ivar];
		return self;
	}
	else
	{
		return [[self class] performSelector: selector withObject: obj];
	}
}

@end
