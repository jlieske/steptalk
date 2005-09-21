/* All Rights reserved */

#include "StepTalkMethod.h"

@implementation StepTalkMethod

- (void) encodeWithCoder: (NSCoder*) coder
{
	//[super encodeWithCoder: coder];
	[coder encodeObject: name];
	[coder encodeObject: signature];
	[coder encodeObject: arguments];
	[coder encodeObject: content];
	[coder encodeObject: returnType];
	[coder encodeObject: metadatas];
}

- (id) initWithCoder: (NSCoder*) coder
{
	//if (self = [super initWithCoder: coder]) 
	{
		ASSIGN (name, [coder decodeObject]);
		ASSIGN (signature, [coder decodeObject]);
		ASSIGN (arguments, [coder decodeObject]);
		ASSIGN (content, [coder decodeObject]);
		ASSIGN (returnType, [coder decodeObject]);
		ASSIGN (metadatas, [coder decodeObject]);
	}
	return self;
}

- (id) init
{
	if (self = [super init])
	{
		name = [NSString new];
		signature = [NSMutableString new];
		arguments = [NSMutableArray new];
		content = [NSString new];
		metadatas = [StepTalkMetadatas new];
	}
	return self;
}

- (void) dealloc
{
	[name release];
	[signature release];
	[arguments release];
	[content release];
	[metadatas release];
}

- (NSString*) description { return [NSString stringWithFormat: @"%@ {%@}",name,content]; }
- (void) setName: (NSString*) aName { ASSIGNCOPY (name, aName); [self parseMethodName]; }
- (void) addArgument: (NSString*) anArgument { [arguments addObject: anArgument]; }
- (void) setContent: (NSString*) aContent { ASSIGNCOPY (content, aContent); }
- (void) setReturnType: (NSString*) aType { ASSIGNCOPY (returnType, aType); }

- (NSString*) name { return name; }
- (NSArray*) arguments { return arguments; }
- (NSString*) argumentAtIndex: (int) index { return [arguments objectAtIndex: index]; }
- (NSString*) content { return content; }
- (NSString*) signature { return signature; }
- (NSString*) returnType { return returnType; }
- (StepTalkMetadatas*) metadatas { return metadatas; }

- (int) numberOfArguments { return [arguments count]; }

- (void) error: (NSException*) exc 
{
	NSLog (@"exception %@ in method %@ : %@", [exc name], 
			signature, [exc reason]);
}

- (void) parseMethodName
{

	NSMutableArray* final = [NSMutableArray new];
	NSArray* array = [name componentsSeparatedByString: @":"];

	[signature release];
	signature = [NSMutableString new];
	[arguments release];
	arguments = [NSMutableArray new];

	int i;
	for (i=0; i<[array count]; i++)
	{
		NSString* str = [array objectAtIndex: i];
		NSArray* arr = [str componentsSeparatedByString: @" "];
		int j;
		for (j=0; j<[arr count]; j++)
		{
			NSString* str = [arr objectAtIndex: j];
			if ([str length] > 0)
			[final addObject: str];
		}
	}

	for (i=1; i<[final count]; i+=2)
	{
		NSString* arg = [final objectAtIndex: i];
		[arguments addObject: arg];
	}

	for (i=0; i<[final count]; i+=2)
	{
		NSString* arg = [final objectAtIndex: i];
		if (i>0) [signature appendString: @":"];
		[signature appendString: arg];
	}

	if ([arguments count] > 0)
		[signature appendString: @":"];

	//NSLog (@"arguments (%d): {%@}", [arguments count], arguments);
	//NSLog (@"signature (%@)", signature);

}

- (id) executeWithDictionary: (NSMutableDictionary*) variables andArguments: (NSArray*) args
{
	int i;
	id result;
	
	if ([args count] == [arguments count])
	{
		for (i=0; i<[args count]; i++)
		{
			[variables setObject: [args objectAtIndex: i] forKey: [arguments objectAtIndex: i]];
		}
		result = [self executeWithDictionary: variables];
	}
	else
	{
		NSLog (@"Error in calling %@, number of arguments incorrects (%d/%d) (%@)", signature, [arguments count], [args count], args);
	}
	return result;
}

- (id) executeWithDictionary: (NSMutableDictionary*) variables
{
	id key;
	id result = nil;

	//NSLog (@"STMethod executeWithDictionary (%@)", variables);

	STEngine* engine = [STEngine engineForLanguageWithName: @"Smalltalk"];
	STEnvironment* env = [[STEnvironment alloc] initWithDefaultDescription];
	NSEnumerator* enumerator = [variables keyEnumerator];

	while ((key = [enumerator nextObject]))
	{
		id obj = [variables objectForKey: key];
		[env setObject: obj forName: key];
	}

	//NSLog (@"pre environment {%@}", [env objectDictionary]);

	NS_DURING
		result = [engine executeCode: content inEnvironment: env];
	NS_HANDLER
		NSLog (@"Execution error in this method: {%@} with env {%@}", content, variables);
		[self error: localException];
	NS_ENDHANDLER
	
	// We change back the variables..
	
	enumerator = [variables keyEnumerator];

	while ((key = [enumerator nextObject]))
	{
		id obj = [env objectWithName: key];
		[variables setObject: obj forKey: key];
	}

	[env release];

	//NSLog (@"STMethod executeWithDictionary (%@) => (%@)", variables, result);

	return result;
}

@end
