//
//  STConversationController.h
//  StepTalk
//
//  Created by Stefan Urbanek on 24.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STContext;
@class STConversation;
@class STTranscriptView;

@protocol STConversationController
- (void)interpretScript:(NSString *)script;
@end

@interface STConversationController : NSObject <STConversationController>{
    STConversation   *conversation;
    
    IBOutlet STTranscriptView *transcript;
}
- (IBAction)takeLanguageFromSender:(id)sender;
- (IBAction)interpret:(id)sender;
- (STConversation *)conversation;

- (NSString *)language;
- (void)setLanguage:(NSString *)language;
@end
