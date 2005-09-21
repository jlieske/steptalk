#include <StepTalkView/StepTalkClass.h>
#include "StepTalkClassInspector.h"

@implementation StepTalkClassInspector

- (void) textDidEndEditing: (NSNotification*) notification
{
	[self ok: self];
}

- (id) init
{
	self = [super init];
    	[NSBundle loadNibNamed:@"StepTalkClassInspector" owner:self];
	id cm = [NSApp classManager];
	NSArray* listOfActions = [cm allActionsForClassNamed: @"StepTalkClass"];
	int i;
	for (i=0; i<[listOfActions count]; i++)
	{
		NSString* action = [listOfActions objectAtIndex: i];
		NSLog (@"  remove %@", action);
		[cm removeAction: action fromClassNamed: @"StepTalkClass"];
	}

    	return self;
}

- (void) syncWithClassManager
{
	StepTalkClass* stc = (StepTalkClass*) [self object];
	id cm = [NSApp classManager];

	if ([cm isKnownClass: [stc name]] == NO)
	{
		[cm addClassNamed: [stc name]
			withSuperClassNamed: @"StepTalkClass"
			withActions: [stc actions]
			withOutlets: [stc outlets]];
	}
	else // class is already known by the class manager
	{
		NSArray* listOfActions = [cm allActionsForClassNamed: [stc name]];
		int i;
		NSLog (@"sync class %@", [stc name]);
		NSLog (@"prev actions: ");
		for (i=0; i<[listOfActions count]; i++)
		{
			NSString* action = [listOfActions objectAtIndex: i];
			NSLog (@"  remove %@", action);
			[cm removeAction: action fromClassNamed: [stc name]];
		}
		listOfActions = [stc actions];
		NSLog (@"set actions: ");
		for (i=0; i<[listOfActions count]; i++)
		{
			NSString* action = [listOfActions objectAtIndex: i];
			NSLog(@"  add %@", action);
			[cm addAction: action forClassNamed: [stc name]];
		}
		listOfActions = [cm allActionsForClassNamed: [stc name]];
		NSLog (@"current actions: ");
		for (i=0; i<[listOfActions count]; i++)
		{
			NSString* action = [listOfActions objectAtIndex: i];
			NSLog (@"  %@", action);
		}
	}
}

- (void) addAction: (id) sender
{
	StepTalkClass* stc = (StepTalkClass*) [self object];
	[stc addMethod: @"newMethod" withContent: @"\" enter your code here \"\n"];
	ASSIGN(lastModifiedMethod, @"newMethod");
	[self syncWithClassManager];
	[self getActions];
}

- (void) removeAction: (id) sender
{
	int row = [actions selectedRow];
	if (row < [methods count])
	{
		StepTalkClass* stc = (StepTalkClass*) [self object];
		[stc removeMethod: [methods objectAtIndex: row]];
		[self syncWithClassManager];
		[self getActions];
	}
}

- (void) addOutlet: (id) sender
{
	StepTalkClass* stc = (StepTalkClass*) [self object];
	[stc addIvar: @"newOutlet"];
	[self getVariables];
}

- (void) removeOutlet: (id) sender
{
	int row = [outlets selectedRow];
	if (row < [variables count])
	{
		StepTalkClass* stc = (StepTalkClass*) [self object];

		[stc removeIvar: [variables objectAtIndex: row]];
		[self getVariables];
	}
}

- (void) ok: (id) sender
{
	StepTalkClass* stc = (StepTalkClass*) [self object];
	NSString* prevMethodName = [[currentMethod name] copy];
	NSString* methodName = [methodSignature stringValue];

	[currentMethod setContent: [[textviewCode textStorage] string]];
	switch ([[returnType selectedItem] tag])
	{
		case 0:
			[currentMethod setReturnType: @"id"];
			break;
		case 1:
			[currentMethod setReturnType: @"int"];
			break;
		case 2:
			[currentMethod setReturnType: @"void"];
	}

	if (![prevMethodName isEqualToString: methodName])
	{
		[stc renameMethod: prevMethodName to: methodName];
		ASSIGN(lastModifiedMethod, methodName);
		[self syncWithClassManager];
	}

	[prevMethodName release];

	[self getVariables];
	[self getActions];
	[super ok:sender];
}

- (void) revert: (id) sender
{
	[methodSignature setStringValue: @""];
	NSMutableAttributedString* content = [NSMutableAttributedString new];
	[[textviewCode textStorage] setAttributedString: content];
	[content release];
	
	[self getVariables];
	[self getActions];
	[super revert:sender];
}

- (void) getVariables
{
	[variables release];
	StepTalkClass* stc = (StepTalkClass*) [self object];
	variables = [[stc variablesArray] retain];
	[outlets reloadData];
}

- (void) getActions
{
	[methods release];
	StepTalkClass* stc = (StepTalkClass*) [self object];
	methods = [[stc methodsArray] retain];
	[actions reloadData];
	if ([methods count] > 0)
	{
		// not specially efficient, but we shouldn't have lots of methods..
		int i;
		int index = 0;
		for (i=0; i< [methods count]; i++)
		{
			NSString* method = [methods objectAtIndex: 0];
			if ([lastModifiedMethod isEqualToString: method])
			{
				index = i;
				break;
			}	
		}
		[actions selectRow: index byExtendingSelection: NO];
		[self tableView: actions shouldSelectRow: index];
	}
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	int ret = 0;
	if (aTableView == outlets)
	{
		ret = [variables count];
	}
	if (aTableView == actions)
	{
		ret = [methods count];
	}
    	return ret;
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
	id val;
        if (aTableView == outlets)
	{
		val = [variables objectAtIndex: rowIndex];
	}
	if (aTableView == actions)
	{
		StepTalkMethod* method = [methods objectAtIndex: rowIndex];
		val = [method signature];
	}
	return val;
}

- (void)tableView:  (NSTableView *) aTableView
    setObjectValue: (id) newKey
    forTableColumn: (NSTableColumn *) aTableColumn
    row: (int) rowIndex
{
	if (newKey != nil)
	{
		if (aTableView == outlets)
		{
			NSLog (@"tableview == outlets");
			id prev = [variables objectAtIndex: rowIndex];
			StepTalkClass* stc = (StepTalkClass*) [self object];
			[stc renameIvar: prev to: newKey];
			[self getVariables];
		}
		if (aTableView == actions)
		{
			//TODO
			/*
			id prev = [variables objectAtIndex: rowIndex];
			StepTalkClass* stc = (StepTalkClass*) [self object];
			[stc renameIvar: prev to: newKey];
			[self getVariables];
			*/
		}
	}
}

- (BOOL) tableView: (NSTableView *)aTableView
   shouldSelectRow: (int)rowIndex
{
	if (aTableView == actions)
	{
		StepTalkMethod* method = [methods objectAtIndex: rowIndex];
		[currentMethod release];
		currentMethod = [method retain];
		[methodSignature setStringValue: [method name]];
		NSMutableAttributedString* content = 
			[[NSMutableAttributedString alloc] 
			initWithString: [method content]];
		[[textviewCode textStorage] setAttributedString: content];
		NSString* retType = [method returnType];
		[returnType selectItemWithTitle: retType];
	}
	return YES;
}

@end
