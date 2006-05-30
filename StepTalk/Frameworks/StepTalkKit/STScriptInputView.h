//
//  STScriptInputView.h
//  StepTalking
//
//  Created by Stefan Urbanek on 15.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "STConversationController.h"
@interface STScriptInputView : NSTextView {
    NSMutableArray *history;
    unsigned int    historySize;
    unsigned int    historyPointer;
    NSString        *currentScript;
    
    IBOutlet id <STConversationController> conversationController;
}
- (IBAction)recallPreviousScript:(id)sender;
- (IBAction)recallNextScript:(id)sender;
- (IBAction)cleanInputAndSaveHistory:(id)sender;

- (void)setConversationController:(id <STConversationController>)anObject;
- (id <STConversationController>)conversationController;
@end

