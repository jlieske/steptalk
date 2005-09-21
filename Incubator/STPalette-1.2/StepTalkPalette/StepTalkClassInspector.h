#include <AppKit/AppKit.h>
#include <InterfaceBuilder/InterfaceBuilder.h>
#include <StepTalkView/StepTalkMethod.h>

@interface StepTalkClassInspector : IBInspector
{
	NSTextView* textviewCode;
	NSTextField* methodSignature;
	NSTableView* outlets;
	NSTableView* actions;
	NSPopUpButton* returnType;
@private
	NSMutableArray* variables;
	NSMutableArray* methods;
	StepTalkMethod* currentMethod;
	NSString* lastModifiedMethod;
}
- (void) getActions;
- (void) getVariables;
@end
