#include <AppKit/AppKit.h>
#include <InterfaceBuilder/InterfaceBuilder.h>

@interface GormConnectionInspector : IBInspector
{
	id                    currentConnector;
	NSMutableArray        *connectors;
	NSArray               *actions;
	NSArray               *outlets;
	NSBrowser             *newBrowser;
	NSBrowser             *oldBrowser;
} 
@end

@implementation GormConnectionInspector (st)
@end

@interface StepTalkConnectionInspector : GormConnectionInspector
{
}
@end
