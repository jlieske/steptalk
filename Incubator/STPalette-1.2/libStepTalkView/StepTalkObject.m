/* All Rights reserved */

#include "StepTalkObject.h"

@implementation StepTalkObject

- (void) encodeWithCoder: (NSCoder*) coder
{
	//[super encodeWithCoder: coder];
	[coder encodeObject: script];
	[coder encodeObject: variables];
}

- (id) initWithCoder: (NSCoder*) coder
{
	//if (self = [super initWithCoder: coder]) 
	{
		ASSIGN (script, [coder decodeObject]);
		ASSIGN (variables, [coder decodeObject]);

		[self setOutlets];
	}
	return self;
}

- (id) init
{
	if (self = [super init])
	{
		variables = [NSMutableDictionary new];
	}
	return self;
}

- (void) dealloc
{
	[variables release];
	[super dealloc];
}

- (void) setTitle: (NSString*) aTitle { ASSIGN (title, aTitle); }
- (NSString*) title { return title; }

- (void) addIVar: (NSString*) name
{
	id obj = [variables objectForKey: name];
	if (obj == nil) // no var..
	{
		[self setIVar: @"" withName: name];
		[self setOutlets];
	}
}

- (void) removeIVar: (NSString*) name
{
	[variables removeObjectForKey: name];
}

- (void) renameIVar: (id) key to: (id) name
{
	id prev = [[variables objectForKey: key] copy];
	if (prev != nil)
	{
		[variables setObject: prev forKey: name];
		[prev release];
		[variables removeObjectForKey: key];
		[self setOutlets];
	}
}

- (void) setIVar: (id) obj withName: (NSString*) name
{
	NSLog (@"setIVar (%@) withName: (%@)", obj, name);
	[variables setObject: obj forKey: name];
}

- (id) ivarWithName: (NSString*) name
{
	return [variables objectForKey: name];
}

- (NSMutableDictionary*) variables { return variables; }
- (NSMutableArray*) variablesArray 
{
       NSMutableArray* array = [NSMutableArray new];
	NSEnumerator* enumerator = [variables keyEnumerator];
 	id key;
	while ((key = [enumerator nextObject]))
	{
		[array addObject: key];
	}
	return [array autorelease];
}

- (NSString*) script { return script; }

- (void) setScript: (NSString*) aScript 
{
	NSLog (@"setScript: %@", aScript);
	ASSIGNCOPY (script, aScript);
}

- (void) execute: (id) sender
{
	STEnvironment *env = [STEnvironment sharedEnvironment];

	NSEnumerator *enumerator = [variables keyEnumerator];
	id key;

	while ((key = [enumerator nextObject])) {
		id obj = [variables objectForKey: key];
		[env setObject: obj forName: key];
		NSLog (@"env set object: %@ for key: %@", obj, key);
	}

	STEngine *engine = [STEngine engineForLanguageWithName: @"Smalltalk"];
	id result;

	NSLog (@"we execute the script: {{%@}}", script);

	NS_DURING
		result = [engine executeCode: script inEnvironment: env];
	NS_HANDLER
		NSLog (@"Execution Error in the Script !");
	NS_ENDHANDLER
}

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
	/*
	id cm = [NSApp classManager];

	NSArray* outlets = [cm extraOutletsForObject: self];
	NSLog (@"outlets <%@>", outlets);
	*/

	NSEnumerator* enumerator = [variables keyEnumerator];
	id key;
	while ((key = [enumerator nextObject])) 
	{
		NSLog (@"add outlet %@", key);
		//[cm addOutlet: key forClassNamed: @"StepTalkObject"];
		NSString* method = [NSString stringWithFormat: @"set%@%@:", 
			[[key substringToIndex: 1] uppercaseString],
			[key substringFromIndex: 1]];
		NSLog (@"add sel (%@)", method);
		SEL retsel = GSSelectorFromNameAndTypes ([method cString], NULL);
		NSLog (@"retsel(%d): %@", retsel, NSStringFromSelector(retsel));
	}
}

@end
