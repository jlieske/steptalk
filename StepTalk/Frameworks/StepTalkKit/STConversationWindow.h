//
//  STConversationWindow.h
//  StepTalk
//
//  Created by Stefan Urbanek on 24.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STScriptInputView;
@class STTranscriptView;
@class STConversationController;
@class STContext;

@interface STConversationWindow : NSWindow {
    IBOutlet STConversationController *conversationController;
    IBOutlet STScriptInputView        *inputView;
    IBOutlet STTranscriptView         *transcript;
             NSPopUpButton            *languagesPopUp;

    IBOutlet NSView                   *_contents;
}
- (void)setContext:(STContext *)context;
- (STContext *)context;

- (void)interpret:(id)sender;
- (void)interpretAndKeep:(id)sender;
- (void)cleanTranscript:(id)sender;
@end
