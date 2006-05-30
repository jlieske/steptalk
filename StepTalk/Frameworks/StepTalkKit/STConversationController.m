//
//  STConversationController.m
//  StepTalk
//
//  Created by Stefan Urbanek on 24.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "STConversationController.h"

#import <StepTalk/StepTalk.h>
#import "STScriptInputView.h"
#import "STTranscriptView.h"

@implementation STConversationController
- init
{
    STContext *context;
    
    self = [super init];
    
    context = [STEnvironment environmentWithDefaultDescription];
    [context retain];
    [context setObject:context forName:@"Environment"];
    
    conversation = [[STConversation alloc] initWithContext:context
                                                  language:@"Smalltalk"];

    return self;
}
- (NSString *)language
{
    return [conversation language];
}
- (void)setLanguage:(NSString *)language
{
    [conversation setLanguage:language];
}

- (STConversation *)conversation
{
    return conversation;
}
- (void)interpretScript:(NSString *)script
{
    NSString *string;
    id        result = nil;

    /* FIXME: hack */
    if(![script hasSuffix:@"\n"])
    {
        script = [script stringByAppendingString:@"\n"];
    }
    [transcript displayString:script formatting:STScriptFormatting];

    /* Interpret the script and get the result */
    @try {
        [conversation interpretScript:script];
    }
    @catch (NSException *exception) {
        string = [NSString stringWithFormat:@"Exception: %@\nReason: %@\n",
            [exception name], [exception  reason]];
        [transcript displayString:string formatting:STErrorFormatting];
    }
    @finally {
        /* FIXME: Do nothing at the moment */
    }
    result = [conversation result];
    
    string = [transcript stringFromObject:result];
    string = [string stringByAppendingString:@"\n"];
    [transcript displayString:string formatting:STResultFormatting];
    
}
- (void)setTranscript:(STTranscriptView *)aView
{
    ASSIGN(transcript, aView);
    NSLog(@"Setting %@ to %@", transcript, [conversation context]);
    [[conversation context] setObject:transcript forName:@"Transcript"];
}
@end
