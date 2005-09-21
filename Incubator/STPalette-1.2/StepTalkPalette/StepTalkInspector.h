#include <AppKit/AppKit.h>
#include <InterfaceBuilder/InterfaceBuilder.h>

@interface StepTalkInspector : IBInspector
{
	NSTextView* textView;
	NSTextField* name;
	NSTableView* outlets;
@private
	NSMutableArray* variables;
}
- (void) getVariables;
@end
