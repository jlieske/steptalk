//
//  STScriptInputView.m
//  StepTalking
//
//  Created by Stefan Urbanek on 15.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "STScriptInputView.h"

#import <StepTalk/StepTalk.h>

@implementation STScriptInputView
- (void)initHistory
{
    historySize = 50;
    history = [[NSMutableArray alloc] init];
}
- (unsigned int)historySize
{
    return historySize;
}
- (void)setHistorySize:(unsigned int)size
{
    historySize = size;
}
- (NSString *)script
{
    return [[[self string] copy] autorelease];
}
-(void)saveInHistory:(NSString *)source
{
    int i;
    if(!history)
    {
        [self initHistory];
    }
    [history insertObject:[[source copy] autorelease] atIndex:0];
    historyPointer = 0;
    [currentScript release];
    currentScript = nil;
    
    if(historySize == 0)
    {
        [history removeAllObjects];
    }
    else
    {
        while([history count] >= historySize)
        {
            [history removeLastObject];
        }
    }
}
- (void)recallPreviousScript:(id)sender
{
    if(historyPointer >= historySize || historyPointer >= [history count])
    {
        return;
    }
    if(currentScript == 0)
    {
        currentScript = [[self string] copy];
        
        [self setString:[history objectAtIndex:historyPointer]];
    }
    else
    {
        if(historyPointer < historySize-1 && historyPointer < [history count]-1)
        {
            historyPointer = historyPointer + 1;
            [self setString:[history objectAtIndex:historyPointer]];
        }
    }
    [self setNeedsDisplay:YES];
}
- (void)recallNextScript:(id)sender
{
    if(historyPointer == 0 && currentScript != nil)
    {
        [self setString:currentScript];
        [currentScript release];
        currentScript = 0;
    }
    else if(historyPointer > 0)
    {
        historyPointer = historyPointer - 1;
        [self setString:[history objectAtIndex:historyPointer]];
    }
}
- (IBAction)cleanInputAndSaveHistory:(id)sender
{
    [self saveInHistory:[self string]];
    [self setString:@""];
}
- (void)setConversationController:(id <STConversationController>)anObject
{
    [anObject retain];
    [conversationController release];
    conversationController = anObject;
}
- (id <STConversationController>)conversationController
{
    return conversationController;
}

- (void)keyDown:(NSEvent *)event
{
    unsigned int   flags = [event modifierFlags];
    NSString      *characters = [event characters];
    unichar        keyChar = [characters characterAtIndex:0];

    if(keyChar == NSEnterCharacter || keyChar == NSCarriageReturnCharacter)
    {
        if(flags & NSAlternateKeyMask)
        {
            [self insertNewline:self];
        }
        else if (flags & NSControlKeyMask)
        {
            [[self delegate] interpretAndKeep:self];
        }
        else
        {
            [[self delegate] interpret:self];
        }
        return;
    }
    else if(flags & NSAlternateKeyMask)
    {
        if(keyChar == NSUpArrowFunctionKey)
        { 
            [self recallPreviousScript:self];
            return;
        }
        else if (keyChar == NSDownArrowFunctionKey)
        {
            [self recallNextScript:self];
            return;
        }
    }
    else if(flags & NSCommandKeyMask)
    {
        if(keyChar == NSUpArrowFunctionKey)
        {
            NSLog(@"Scroll conversation up");
            return;
        }
        else if (keyChar == NSDownArrowFunctionKey)
        {
            NSLog(@"Scroll conversation down");
            return;
        }
    }

    [super keyDown:event];
}
@end
