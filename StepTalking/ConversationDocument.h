//
//  ConversationDocument.h
//  StepTalking
//
//  Created by Stefan Urbanek on 14.5.2006.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class STConversation;
@class STEnvironment;
@class Transcript;

@interface ConversationDocument : NSDocument
{
    STEnvironment *environment;
    STConversation *conversation;
    
    Transcript     *transcript;
    
    NSDictionary *resultAttributes;
    NSDictionary *scriptAttributes;
    NSDictionary *errorAttributes;

    NSTextView *conversationView;
    NSTextView *scriptEditor;
    NSPopUpButton *languagesPopUp;
    
    NSMutableArray *history;
    unsigned int    historySize;
    unsigned int    historyPointer;
    NSString        *currentScript;
}
@end
