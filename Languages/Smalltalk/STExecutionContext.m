/**
    STExecutionContext.m
 
    Copyright (c) 2002 Free Software Foundation
 
    This file is part of the StepTalk project.
 
 */

#import "STExecutionContext.h"

#import "STMethodContext.h"
#import "STStack.h"

#import <Foundation/NSDebug.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

static unsigned nextId = 1;

@interface STExecutionContext(STPrivate)
- (unsigned)contextId;
@end

@implementation STExecutionContext
- initWithStackSize:(unsigned)stackSize
{
    stack = [[STStack alloc] initWithSize:stackSize];

    contextId = nextId ++;

    return [super init];
}
- (void)dealloc
{
    RELEASE(stack);
    [super dealloc];
}
- (unsigned)contextId
{
    return contextId;
}
- (NSString *)description
{
    NSMutableString *str;
    str = [NSMutableString stringWithFormat:
                              @"%@ %i (home %i)",
                              [self className],
                              contextId,
                              [[self homeContext] contextId]];
    return str;
}
- (void)invalidate
{
    [self subclassResponsibility:_cmd];
}
- (BOOL)isValid
{
    [self subclassResponsibility:_cmd];
    return NO;
}
- (unsigned)instructionPointer
{
    return instructionPointer;
}
- (void)setInstructionPointer:(unsigned)value
{
    instructionPointer = value;
}
- (STMethodContext *)homeContext
{
    [self subclassResponsibility:_cmd];
    return nil;
}
- (void)setHomeContext:(STMethodContext *)newContext
{
    [self subclassResponsibility:_cmd];
}

- (STStack *)stack
{
    return stack;
}
- (BOOL)isBlockContext;
{
    [self subclassResponsibility:_cmd];
    return NO;
}
- (id)temporaryAtIndex:(unsigned)index
{
    [self subclassResponsibility:_cmd];
    return nil;
}
- (void)setTemporary:anObject atIndex:(unsigned)index
{
    [self subclassResponsibility:_cmd];
}
- (id)externAtIndex:(unsigned)index
{
    [self subclassResponsibility:_cmd];
    return nil;
}
- (void)setExtern:anObject atIndex:(unsigned)index
{
    [self subclassResponsibility:_cmd];
}
- (STBytecodes *)bytecodes
{
    [self subclassResponsibility:_cmd];
    return nil;
}
- (id)literalObjectAtIndex:(unsigned)index
{
    [self subclassResponsibility:_cmd];
    return nil;
}
- (id)receiver
{
    [self subclassResponsibility:_cmd];
    return nil;
}
@end
