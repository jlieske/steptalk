/**
    STUndefinedObject.m
    Wrapper for nil object
 
    Copyright (c) 2002 Free Software Foundation
 
    This file is part of the StepTalk project.
 
 */
#import "STUndefinedObject+additions.h"

#import "STBlock.h"
#import <StepTalk/STExterns.h>

#import <Foundation/NSString.h>
#import <Foundation/NSException.h>

@implementation STUndefinedObject(SmalltalkAdditions)
- (BOOL)isNil
{
    return YES;
}

- ifNil:(STBlock *)block
{
    return [block value];
}

- notNil:(STBlock *)block
{
    return nil;
}

- ifFalse:(STBlock *)block
{
    return [block value];
}

- ifTrue:(STBlock *)block
{
    return nil;
}

- ifFalse:(STBlock *)block ifTrue:(STBlock *)anotherBlock
{
    return [block value];
}

- ifTrue:(STBlock *)block ifFalse:(STBlock *)anotherBlock
{
    return [anotherBlock value];
}
@end

