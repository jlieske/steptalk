#include <StepTalkView/StepTalkView.h>
#include "StepTalkInspector.h"

@implementation StepTalkInspector

- (id) init
{
	self = [super init];
    	[NSBundle loadNibNamed:@"StepTalkInspector" owner:self];
	NSLog (@"init inspector, outlets: %@", outlets);
    	return self;
}

- (void) addOutlet: (id) sender
{
	StepTalkView* stv = (StepTalkView*) [self object];
	[stv addIVar: @"newOutlet"];
	[self getVariables];
}

- (void) removeOutlet: (id) sender
{
	int row = [outlets selectedRow];
	if (row < [variables count])
	{
		StepTalkView* stv = (StepTalkView*) [self object];

		[stv removeIVar: [variables objectAtIndex: row]];
		[self getVariables];
	}
}

- (void) ok: (id) sender
{
	StepTalkView* stv = (StepTalkView*) [self object];
	[stv setScript: [[textView textStorage] string]];
	[stv setTitle: [name stringValue]];
	[self getVariables];
	[super ok:sender];
}

- (void) revert: (id) sender
{
	StepTalkView* stv = (StepTalkView*) [self object];
	NSString* script = [stv script];
	NSMutableAttributedString* ascript = [[NSMutableAttributedString alloc] 
		initWithString: script];
	[[textView textStorage] setAttributedString: ascript];
	[name setStringValue: [stv title]];
	[self getVariables];
	[super revert:sender];
}

- (void) getVariables
{
	[variables release];
	StepTalkView* stv = (StepTalkView*) [self object];
	variables = [[stv variablesArray] retain];
	NSLog (@"getVariables(%@)", variables);
	[outlets reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	int ret = [variables count];
	NSLog (@"nb of rows (%d)", ret);
    	return ret;
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
	id val = [variables objectAtIndex: rowIndex];
	return val;
}

- (void)tableView:  (NSTableView *) aTableView
    setObjectValue: (id) newKey
    forTableColumn: (NSTableColumn *) aTableColumn
    row: (int) rowIndex
{
	if (newKey != nil)
	{
		id prev = [variables objectAtIndex: rowIndex];
		StepTalkView* stv = (StepTalkView*) [self object];
		[stv renameIVar: prev to: newKey];
		[self getVariables];
	}
}

@end
