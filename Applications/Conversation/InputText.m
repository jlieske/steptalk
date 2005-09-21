#import "InputText.h"
#import <AppKit/NSEvent.h>

@implementation InputText
- (void) keyDown:(NSEvent *) theEvent
{
    NSString *characters;
    unichar character;

    characters = [theEvent characters];
    character = 0;

    if ( [characters length] > 0 )
    {
        character = [characters characterAtIndex: 0];
      
        switch ( character )
        {
        case '\n':
        case '\r':
                if ( [theEvent modifierFlags] & NSControlKeyMask )
                {
                    [controller say:self];
                }
                break;
        case '\t':
                [controller complete:self];
                break;
        default:
            [super keyDown:theEvent];
        }
    }
    else
    {
        [super keyDown:theEvent];
    };
}
- (void)setController:(ConversationController *)aController
{
    controller = aController;
}
@end
