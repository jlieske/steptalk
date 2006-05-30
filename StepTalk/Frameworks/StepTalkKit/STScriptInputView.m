//
//  STScriptEditor.m
//  StepTalking
//
//  Created by Stefan Urbanek on 15.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "STScriptEditor.h"


@implementation STScriptEditor
- (void)keyDown:(NSEvent *)event
{
    unsigned int   flags = [event modifierFlags];
    NSString      *characters = [event characters];
    unichar        keyChar = [characters characterAtIndex:0];

    if(flags & NSAlternateKeyMask)
    {
        if(keyChar == NSUpArrowFunctionKey)
        { 
            [[self delegate] recallPreviousScript:self];
            return;
        }
        else if (keyChar == NSDownArrowFunctionKey)
        {
            [[self delegate] recallNextScript:self];
            return;
        }
    }
    else if(flags & NSCommandKeyMask)
    {
        if(keyChar == NSUpArrowFunctionKey)
        {
            NSLog(@"Scroll conversation up");
        }
        else if (keyChar == NSDownArrowFunctionKey)
        {
            NSLog(@"Scroll conversation down");
        }
    }
    [super keyDown:event];
}
@end
