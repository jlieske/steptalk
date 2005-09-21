/* All Rights reserved */

#include "StepTalkClass.h"

@implementation StepTalkClass

/*
 * object initialization..
 * ==============================================================================================
 */

- (void) encodeWithCoder: (NSCoder*) coder
{
	//[super encodeWithCoder: coder];
	[coder encodeObject: variables];
	[coder encodeObject: methods];
	[coder encodeObject: name];
	[coder encodeObject: superClass];
	[coder encodeObject: metadatas];
}

- (id) initWithCoder: (NSCoder*) coder
{
	//if (self = [super initWithCoder: coder]) 
	{
		ASSIGN (variables, [coder decodeObject]);
		ASSIGN (methods, [coder decodeObject]);
		ASSIGN (name, [coder decodeObject]);
		ASSIGN (superClass, [coder decodeObject]);
		ASSIGN (metadatas, [coder decodeObject]);

		[self setActions];
		[self setOutlets];
	}
	return self;
}

- (id) init
{
	//NSLog (@"init..");
	if (self = [super init])
	{
		//NSLog (@"init StepTalkClass");
		variables = [NSMutableDictionary new];
		methods = [NSMutableDictionary new];
		name = [[NSString alloc] initWithString: @"StepTalkClass"];
		metadatas = [StepTalkMetadatas new];
	}
	return self;
}

- (void) dealloc
{
	[variables release];
	[methods release];
	[name release];
	[metadatas release];
	[super dealloc];
}

- (id) initWithName: (NSString*) aName
{
	return [self initWithName: aName parent: @"NSObject"];
}

- (id) initWithName: (NSString*) aName parent: (NSString*) parentName
{
	StepTalkClass* obj = [StepTalkClass new];
	[obj setName: aName];
	[obj setParent: parentName];
	[obj registerClass];
	[obj addIvarsFromSuperclass];
	return obj;
}

/*
 * accessors/modifiers
 * ==============================================================================================
 */

- (StepTalkMetadatas*) metadatas { return metadatas; }

- (BOOL) registerClass
{
	id runtime = [StepTalkRuntime defaultRuntime];
	[runtime addClass: self];
	return YES;
}

- (void) addIvarsFromSuperclass
{
	if ([superClass respondsToSelector: @selector(variables)])
	{
		NSDictionary* ivars = [superClass variables];
		NSEnumerator* enumerator = [ivars keyEnumerator];
		id key;

		while ((key = [enumerator nextObject]))
		{
			[self addIvar: key withValue: [ivars objectForKey: key]];
		}
		[self addIvar: @"self" withValue: self];
	}
}

- (void) setName: (NSString*) aName { ASSIGN (name, aName); } 
- (NSString*) name { return name; }

- (id) superClass { return superClass; }

- (void) setParent: (NSString*) aName 
{ 
	id runtime = [StepTalkRuntime defaultRuntime];
	id class = [runtime classForName: aName];
	if (class == nil) // we can try to get an ObjC class
	{
		class = NSClassFromString(aName);
	}
	ASSIGN (superClass, class);
}

- (void) addMethod: (NSString*) methodName withContent: (NSString*) content
{
	[self addMethod: methodName withContent: content
		returnType: @"id"];
}

- (void) addMethod: (NSString*) methodName withContent: (NSString*) content
	returnType: (NSString*) returnType
{
	//NSLog (@"addMethod: %@ withContent: %@", methodName, content);
	StepTalkMethod* method = [StepTalkMethod new];
	[method setName: methodName];
	[method setContent: content];
	[method setReturnType: returnType];
	[self checkReturnType: method];
	[methods setObject: method forKey: [method signature]];
	SEL retsel = [self getSelectorFromMethod: [method signature]];
	[method release];
}

- (void) removeMethod: (NSString*) methodName
{
	[methods removeObjectForKey: methodName];
}

- (void) checkReturnType: (StepTalkMethod*) method
{
	//FIXME: that's ugly, I should find another way...
	if ([[method signature] isEqualToString: @"awakeFromNib"])
	{
		//NSLog (@"awakeFromNib, we set the return value to void");
		[method setReturnType: @"void"];
	}
}

- (StepTalkMethod*) getMethod: (NSString*) signature
{
	return [methods objectForKey: signature];
}

/*
 * Method invocation
 * ==============================================================================================
 */

- (id) invocationOfMethod: (NSString*) methodSignature withArguments: (NSArray*) args inClass: (id) class
	returnType: (NSString**) type;
{
	//NSLog (@"invocationOfMethod: %@ withArguments: %@ inClass: %@",
	//		methodSignature, args, class);

	StepTalkMethod* method = [methods objectForKey: methodSignature];
	id result;

	//NSLog (@"method: %@", method);

	if (method == nil) // we didn't find it in the methods, 
			   // butwe check if it corresponds to an accessor
	{
		id outlet;
		if ((outlet = [variables objectForKey: methodSignature]))
		{
			*type = @"id";
			return outlet;
		}
		if ((outlet = [self findOutlet: methodSignature]) != nil)
		{
			[self setIvar: outlet withValue: [args objectAtIndex: 0]];
			*type = @"id";
			return nil;
		}
	}

	if (method == nil) // not found in this class ...
	{
		// we call the superclass
		result = [superClass invocationOfMethod: methodSignature withArguments: args 
			inClass: class returnType: type]; 
	}
	else // we found the method, so we execute it.
	{
		//NSLog (@"method returnType: %@", [method returnType]);
	//	*type = [method returnType];

	//	NSLog (@"type: %@", type);

		if ([args count] == 0)
		{
			//NSLog (@"executeWithDictionary(%@)", [class variables]);
			result = [method executeWithDictionary: [class variables]];
			//NSLog (@"result: %@", result);
		}
		else
		{
			//NSLog (@"executeWithDictionary(%@)andArguments:(%@)", [class variables], args);
			result = [method executeWithDictionary: [class variables] andArguments: args];
			//NSLog (@"result: %@", result);
		}
	}

	//NSLog (@"invocationOfMethod: %@ withArguments: %@ inClass: %@ => (%@)",
	//		methodSignature, args, class, result);

	return result;
}

- (void) forwardInvocation: (NSInvocation*) anInvocation
{
	id result;
	int i;
	NSString* methodSignature = NSStringFromSelector([anInvocation selector]);
	NSMutableArray* args =  [NSMutableArray new];
	int nbArgs = [[anInvocation methodSignature]  numberOfArguments];
	
	//NSLog (@"invocation : %@", methodSignature);
	//NSLog (@"message return type: %s", [[anInvocation methodSignature] 
	//		methodReturnType]);
	//[anInvocation setType];

	for (i=2; i< nbArgs; i++)
	{
		id arg;
		[anInvocation getArgument: &arg atIndex: i];
		[args addObject: arg];
	}

	//NSLog (@"args: %@", args);
	
	id type = [NSString stringWithString: @"id"];
	result = [self invocationOfMethod: methodSignature withArguments: args inClass: self returnType: &type];
	[args release];

	//FIXME: At the moment, the only correct possibility is returning an object (id)
	//       I think the problem is in the construction of the method signature. 
	//       it should be possible to specify int and char* return type. At least int would be useful :-)
	//       update: tried setting an int as return in the signature, but that doesn't work..

	/*
	if ([type isEqualToString: @"int"])
	{
		int ret = [result intValue];
		[anInvocation setReturnValue: &ret];
		int retval = 0;
		[anInvocation getReturnValue: &retval];
		//[anInvocation setType];
	}
	else if ([type isEqualToString: @"char*"])
	{
		const char* ret = [result cString];
		[anInvocation setReturnValue: &ret];
		//[anInvocation setType];
	}
	else 
	if ([type isEqualToString: @"id"])
	*/
	{
		//NSLog (@"final result: (%@)", result);
	//	if (result != nil)
			[anInvocation setReturnValue: &result];
	//	else
	//		[anInvocation setReturnValue: self];
		//[anInvocation setType];
	}
}

- (NSString*) methodSignatureForSelector: (NSString*) sel withReturnType: (NSString*) type
{
	const char *csel = [sel cString];
	const char *ptr = csel;
	int nbargs = 0;
	int i;

	NSMutableString* selector = [NSMutableString new];
	
	while (*ptr)
	{
		if (*ptr == ':')
		{
			nbargs++;
		}
		ptr++;
	}

	if ([type isEqualToString: @"void"])
	{
		[selector appendString: @"v0@+4:+8"];
	}
	else if ([type isEqualToString: @"int"])
	{
		[selector appendString: @"i0@+4:+8"];
	}
	else
	{
		[selector appendString: @"@0@+4:+8"];
	}

	int base = 12;
	for (i=0; i < nbargs; i++)
	{
		[selector appendString: [NSString stringWithFormat: @"@+%d", base]];
		base += 4;
	}
	
	//NSLog (@"methodSignatureForSelector: %@ ==> %@", sel, selector);
	return [selector autorelease];
}

- (NSMethodSignature*) methodSignatureForSelector: (SEL) aSelector
{
	NSMethodSignature* signature;

	signature = [super methodSignatureForSelector: aSelector];

	if (signature == nil)
	{
		NSString* methodSel = NSStringFromSelector(aSelector);
		StepTalkMethod* method = [methods objectForKey: methodSel]; 
		NSString* sel = [self methodSignatureForSelector: methodSel
			withReturnType: [method returnType]];
		signature = [NSMethodSignature signatureWithObjCTypes: 
			[sel cString]];
	}
	return signature;
}

/*
 * internal variables
 * ==============================================================================================
 */

- (void) addIvar: (NSString*) aName withValue: (id) aValue
{
	[variables setObject: aValue forKey: aName];
}

- (void) removeIvar: (NSString*) aName
{
	[variables removeObjectForKey: aName];
}

- (id) setIvar: (NSString*) aName withValue: (id) aValue
{
	if ([variables objectForKey: aName] != nil)
	{
		[variables setObject: aValue forKey: aName];
		return aValue;
	}
	return nil;
}

- (void) renameMethod: (id) key to: (id) aName
{
	StepTalkMethod* prev = [[methods objectForKey: key] retain];
	if (prev != nil)
	{
		[prev setName: aName];
		SEL retsel = [self getSelectorFromMethod: [prev signature]];
		[self checkReturnType: prev];
		[methods removeObjectForKey: key];
		[methods setObject: prev forKey: [prev signature]];
		[prev release];
		[self setActions];
	}
}

- (void) renameIvar: (id) key to: (id) aName
{
	id prev = [[variables objectForKey: key] copy];
	if (prev != nil)
	{
		[variables setObject: prev forKey: aName];
		[prev release];
		[variables removeObjectForKey: key];
		[self setOutlets];
	}
}

- (id) ivarWithName: (NSString*) aName
{
	return [variables objectForKey: aName];
}

- (void) addIvar: (NSString*) aName
{
	[self addIvar: aName withValue: @""];
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

- (NSMutableArray*) methodsArray 
{
       NSMutableArray* array = [NSMutableArray new];
	NSEnumerator* enumerator = [methods keyEnumerator];
 	id key;
	while ((key = [enumerator nextObject]))
	{
		[array addObject: [methods objectForKey: key]];
	}
	return [array autorelease];
}


/*
 * Other stuff
 * ==============================================================================================
 */

- (SEL) getSelectorFromMethod: (NSString*) method
{
	SEL sel;
	sel = NSSelectorFromString(method);

	if (!sel)
	{
	       	const char *aName = [method cString];
		sel = sel_register_name(aName);
	}
	return sel;
}

- (NSMutableArray*) outlets { return [self variablesArray]; }
- (NSMutableArray*) actions 
{
       NSMutableArray* array = [NSMutableArray new];
	NSEnumerator* enumerator = [methods keyEnumerator];
 	id key;
	while ((key = [enumerator nextObject]))
	{
		[array addObject: key];
	}
	return [array autorelease];
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


- (void) setActions
{
	//NSLog (@"setActions");
	NSEnumerator* enumerator = [methods keyEnumerator];
	id key;
	while ((key = [enumerator nextObject])) 
	{
		SEL retsel = [self getSelectorFromMethod: key];
	}
}

- (void) setOutlets
{
	NSEnumerator* enumerator = [variables keyEnumerator];
	id key;
	while ((key = [enumerator nextObject])) 
	{
		//NSLog (@"add outlet %@", key);
		//[cm addOutlet: key forClassNamed: @"StepTalkObject"];
		NSString* method = [NSString stringWithFormat: @"set%@%@:", 
			[[key substringToIndex: 1] uppercaseString],
			[key substringFromIndex: 1]];
		//NSLog (@"add sel (%@)", method);
		SEL retsel = GSSelectorFromNameAndTypes ([method cString], NULL);
		//NSLog (@"retsel(%d): %@", retsel, NSStringFromSelector(retsel));
	}
}

- (BOOL) respondsToSelector: (SEL) sel
{
	BOOL ret = NO;
	NSString* signature = NSStringFromSelector (sel);
	//NSLog (@"STClass respondsToSelector(%@)", signature);
	id method = [methods objectForKey: signature];

	if (method != nil) ret = YES;
	if ([self findOutlet: signature] != nil) ret = YES;
	
	//NSLog (@"STClass respondsToSelector(%@) => %d", signature, ret);
	return ret;
}

@end
