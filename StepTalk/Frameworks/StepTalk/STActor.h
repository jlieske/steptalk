/**
    STActor
    StepTalk actor
  
    Copyright (c) 2002 Free Software Foundation
  
    Written by: Stefan Urbanek 
    Date: 2005 June 30
    License: LGPL
     
    This file is part of the StepTalk project.
*/

#import <Foundation/Foundation.h>

#import "STMethod.h"

@class STEnvironment;
@class STContext;

@interface STActor:NSObject<NSCoding>
{
    NSMutableDictionary *ivars;
    NSMutableDictionary *methodDictionary;
    id                   traits;
    STContext           *context;
}
+ actorInContext:(STContext *)aContext;
- initWithContext:(STContext *)aContext;
- (void)setContext:(STContext *)aContext;
- (STContext *)context;

- (void)setTraits:(id)anObject;
- (id)traits;

- (void)addMethod:(id <STMethod>)aMethod;
- (void)addMethodWithSource:(NSString *)source
                   language:(NSString *)language;

- (id <STMethod>)methodWithName:(NSString *)aName;
- (void)removeMethod:(id <STMethod>)aMethod;
- (void)removeMethodWithName:(NSString *)aName;
- (NSArray *)methodNames;
- (NSDictionary *)methodDictionary;

- (NSArray *)instanceVariableNames;
- (void)setInstanceVariables:(NSDictionary *)dictionary;
- (NSDictionary *)instanceVarables;

/* Depreciated */
+ actorInEnvironment:(STEnvironment *)env;
- initWithEnvironment:(STEnvironment *)env;
- (void)setEnvironment:(STEnvironment *)env;
- (STEnvironment *)environment;
@end
