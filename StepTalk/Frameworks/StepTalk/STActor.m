/**
    STActor
    StepTalk actor
  
    Copyright (c) 2002 Free Software Foundation
  
    Written by: Stefan Urbanek 
    Date: 2005 June 30
    License: LGPL
     
    This file is part of the StepTalk project.
*/

#import "STActor.h"

#import "NSInvocation+additions.h"
#import "STEngine.h"
#import "STEnvironment.h"
#import "STExterns.h"
#import "STObjCRuntime.h"
#import "STCompat.h"
#import "STContext.h"

@implementation STActor

+ actorInContext:(STContext *)aContext
{
    return AUTORELEASE([[self alloc] initWithContext:aContext]);
}
- initWithContext:(STContext *)aContext
{
    self = [self init];
    [self setContext:aContext];

    return self;
}

/** Return new instance of script object without any instance variables */
+ actorInEnvironment:(STEnvironment *)env
{
    NSLog(@"Warning: environment methods in STActor are depreciated");
    return AUTORELEASE([[self alloc] initWithContext:env]);
}
+ actor
{
    return AUTORELEASE([[self alloc] init]);
}
- init
{
    self = [super init];    
    methodDictionary = [[NSMutableDictionary alloc] init];
    ivars = [[NSMutableDictionary alloc] init];
    return self;
}
- initWithEnvironment:(STEnvironment *)env;
{
    NSLog(@"Warning: environment methods in STActor are depreciated");

    return [self initWithContext:env];
}
- (void)dealloc
{
    RELEASE(methodDictionary);
    RELEASE(ivars);
    [super dealloc];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    /* try to set traits value. if there is no such key, then set actors key */
    if([ivars objectForKey:key] != nil)
    {
        [ivars setValue:value forKey:key];
    }
    else
    {
        if(traits)
        {
            @try {
                [traits setValue:value forKey:key];
                return;
            }
            @catch(NSException *exception)
            {
                if(![[exception name] isEqualToString:NSUndefinedKeyException])
                {
                    @throw;
                }
            }
        }
        
        [super setValue:value forKey:key];
    }
}
- (id)valueForKey:(NSString *)key
{
    id value = nil;
        
    value = [ivars objectForKey:key];
    
    if(value == nil)
    {

        if(traits)
        {
            @try {
                value = [traits valueForKey:key];
                return value;
            }
            @catch(NSException *exception)
            {
                if(![[exception name] isEqualToString:NSUndefinedKeyException])
                {
                    @throw;
                }
            }
        }

        value = [super valueForKey:key];
    }
    return value;
}
- (void)setTraits:(id)anObject
{
    [anObject retain];
    [traits release];
    traits = anObject;
}
- (id)traits
{
    return traits;
}

- (NSArray *)instanceVariableNames
{
    return [ivars allKeys];
}
- (void)setInstanceVariables:(NSDictionary *)dictionary
{
    [ivars removeAllObjects];
    [ivars addEntriesFromDictionary:dictionary];
}
- (NSDictionary *)instanceVarables
{
    return [NSDictionary dictionaryWithDictionary:ivars];
}
- (void)addMethod:(id <STMethod>)aMethod
{
    [methodDictionary setObject:aMethod forKey:[aMethod methodName]];
}
- (void)addMethodWithSource:(NSString *)source
                   language:(NSString *)language
{
    id <STMethod>method;
    STEngine *engine;
    engine = [STEngine engineForLanguage:language];  
    method = [engine methodFromSource:source
                          forReceiver:self
                            inContext:context];
    [self addMethod:method];
}
- (id <STMethod>)methodWithName:(NSString *)aName
{
    return [methodDictionary objectForKey:aName];
}
- (void)removeMethod:(id <STMethod>)aMethod
{
    [self notImplemented:_cmd];
}
- (void)removeMethodWithName:(NSString *)aName
{
    [methodDictionary removeObjectForKey:aName];
}
- (NSArray *)methodNames
{
    return [methodDictionary allKeys];
}
- (NSDictionary *)methodDictionary
{
    return [NSDictionary dictionaryWithDictionary:methodDictionary];
}
/** Set object's environment. Note: This method should be replaced by
some other, more clever mechanism. */
- (void)setEnvironment:(STEnvironment *)env
{
    NSLog(@"Warning: environment methods in STActor are depreciated");

    [self setContext:env];
}
- (void)setContext:(STContext *)aContext
{
    ASSIGN(context, aContext);
}

- (STEnvironment *)environment
{
    NSLog(@"Warning: environment methods in STActor are depreciated");

    return [self context];
}
- (STContext *)context
{
    return context;
}
- (BOOL)respondsToSelector:(SEL)aSelector
{
    if( [super respondsToSelector:(SEL)aSelector] )
    {
        return YES;
    }
    
    return ([methodDictionary objectForKey:NSStringFromSelector(aSelector)] != nil);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature = nil;
    
    signature = [super methodSignatureForSelector:sel];

    if(!signature)
    {
        signature = STConstructMethodSignatureForSelector(sel);
    }

    return signature;
}

- (void) forwardInvocation:(NSInvocation *)invocation
{
    STEngine       *engine;
    id <STMethod>   method;
    NSString       *methodName = NSStringFromSelector([invocation selector]);
    NSMutableArray *args;
    id              arg;
    int             index;
    int             count;
    id              retval = nil;

    method = [methodDictionary objectForKey:methodName];
    
    if(!method)
    {
        /* Try to forward to traits */
            /* Note: we do not try to find whether traits responds to selector,
                    as it can forward the message or handle it other way...*/
        [traits forwardInvocation:invocation];

        /*FIXME: do we need exception handler here? */
    }
    else
    {

        engine = [STEngine engineForLanguage:[method languageName]];   

        /* Get arguments as array */
        count = [[invocation methodSignature] numberOfArguments];
        args = [NSMutableArray array];
        
        for(index = 2; index < count; index++)
        {
            arg = [invocation getArgumentAsObjectAtIndex:index];

            if (arg == nil)
            { 
                [args addObject:STNil];
            }
            else 
            { 
                [args addObject:arg];
            } 
        }

        retval = [engine executeMethod:method
                           forReceiver:self
                         withArguments:args
                             inContext:context];

        [invocation setReturnValue:&retval];
    }
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:methodDictionary];
    [coder encodeObject:ivars];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; //[super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &methodDictionary];
    [decoder decodeValueOfObjCType: @encode(id) at: &ivars];
    return self;
}
@end
