#import <Foundation/NSObject.h>

@class NSTextView;
@class NSPopUpButton;
@class NSWindow;
@class STConversation;
@class STContext;
@class InputText;

@interface ConversationController:NSObject
{
    InputText       *inputText;
    NSTextView      *dialogText;
    NSPopUpButton   *languageList;
    NSWindow        *window;
    
    STConversation  *conversation;
    STContext       *context;
}
@end
