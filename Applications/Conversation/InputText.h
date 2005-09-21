#import <AppKit/NSTextView.h>

@class ConversationController;

@interface InputText:NSTextView
{
    ConversationController *controller;
}
- (void)setController:(ConversationController *)aController;
@end
