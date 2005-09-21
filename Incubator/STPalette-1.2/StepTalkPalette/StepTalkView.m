/* All Rights reserved */

#include <AppKit/AppKit.h>
#include <StepTalkView/StepTalkView.h>
#include <GNUstepBase/GSObjCRuntime.h>
#include "StepTalkPalette.h"

@implementation StepTalkView (StepTalkPaletteInspector)

- (NSString*) findOutlet: (NSString*) sel
{
	NSEnumerator* enumerator = [variables keyEnumerator];
	id key;
	while ((key = [enumerator nextObject])) 
	{
		NSString* method = [NSString stringWithFormat: @"set%@%@:", 
			[[key substringToIndex: 1] uppercaseString],
			[key substringFromIndex: 1]];
		if ([sel isEqualToString: method])
		{
			return key;
		}
	}
	return nil;
}

- (id) performSelector: (SEL) selector withObject: (id) obj
{
	NSString* sel = NSStringFromSelector(selector);
	NSLog (@"performSelector (%@) withObject: (%@)", sel, obj);

	NSString* ivar = [self findOutlet: sel];
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

- (BOOL) respondsToSelector: (SEL) selector
{
	NSString* sel = NSStringFromSelector(selector);
	NSLog (@"respondsToSelector (%@)", sel);

	if ([self findOutlet: sel] != nil)
	{
		NSLog (@"findOutlet(%@) YES", sel);
		return YES;
	}
	BOOL ret = [[self class] instancesRespondToSelector: selector];
	NSLog (@"respondsToSelector (%@) -> (%d)", sel, ret);
	return ret;
}

- (void) setOutlets
{
	NSLog (@"setOutlets");
	id cm = [NSApp classManager];

	NSArray* outlets = [cm extraOutletsForObject: self];
	NSLog (@"outlets <%@>", outlets);

	NSEnumerator* enumerator = [variables keyEnumerator];
	id key;
	while ((key = [enumerator nextObject])) 
	{
		NSLog (@"add outlet %@", key);
		[cm addOutlet: key forClassNamed: @"StepTalkView"];
		NSString* method = [NSString stringWithFormat: @"set%@%@:", 
			[[key substringToIndex: 1] uppercaseString],
			[key substringFromIndex: 1]];
		NSLog (@"add sel (%@)", method);
		SEL retsel = GSSelectorFromNameAndTypes ([method cString], NULL);
		NSLog (@"retsel(%d): %@", retsel, NSStringFromSelector(retsel));
	}
	
	//[cm addOutlet: @"TestANico" forClassNamed: @"StepTalkView"];
	//[cm addAction: @"ActionNico:" forClassNamed: @"StepTalkView"];
}

@end

