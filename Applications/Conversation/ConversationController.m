#import "ConversationController.h"

#import "NSObject+NibLoading.h"

#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>

#import <AppKit/NSWorkspace.h>
#import <AppKit/NSTextView.h>

#import <StepTalk/STLanguage.h>
#import <StepTalk/STContext.h>
#import <StepTalk/STEnvironment.h>
#import <StepTalk/STConversation.h>

static NSDictionary  *userAttributes;
static NSDictionary  *outputAttributes;
static NSDictionary  *errorAttributes;

@implementation ConversationController
+ (void)initialize
{
    userAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSColor blackColor], NSForegroundColorAttributeName,
                                [NSFont systemFontOfSize:0], NSFontAttributeName,
                                nil, nil];
    outputAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSColor blackColor], NSForegroundColorAttributeName,
                                [NSFont boldSystemFontOfSize:0], NSFontAttributeName,
                                nil, nil];

    errorAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSColor redColor], NSForegroundColorAttributeName,
                                [NSFont boldSystemFontOfSize:0], NSFontAttributeName,
                                nil, nil];
}
- init
{
    self = [super init];
    
    if(![self loadMyNibNamed:@"ConversationWindow"])
    {
        [NSException raise:@"ConversationException"
                     format:@"Unable to load Conversation Window resources"];
        [self dealloc];
        return nil;
    }
    
    context = [STEnvironment environmentWithDefaultDescription];

    [self defineStandardObjects];

    RETAIN(context);
    
    conversation = [[STConversation alloc] initWithContext:context
                                                  language:nil];
    [self updateLanguageList];
    
    [inputText setController:self];
    
    return self;
}
- (void)dealloc
{
    RELEASE(context);
    RELEASE(conversation);
    [super dealloc];
}
- (void)defineStandardObjects
{
    [context setObject:self forName:@"Shell"];
    [context setObject:self forName:@"Transcript"];
    [context setObject:[NSFileManager defaultManager] forName:@"FileManager"];
    [context setObject:[NSWorkspace sharedWorkspace] forName:@"Workspace"];
    [context setObject:context forName:@"Environment"];
    [context setObject:context forName:@"Context"];
}

- (void)updateLanguageList
{
    NSEnumerator *enumerator;
    NSString     *languageName;
    
    enumerator = [[conversation knownLanguages] objectEnumerator];
    
    [languageList removeAllItems];
    
    while( (languageName = [enumerator nextObject]) )
    {
        [languageList addItemWithTitle:languageName];
    }
}
- (NSWindow *)window
{
    return window;
}
- (void)say:(id)sender
{
    NSString *script = [inputText string];
    id        result;

    result = [self executeScript:script];
    
    [self displayString:[script stringByAppendingString:@"\n"]
             attributes:userAttributes];
    [self displayResult:result];

    [inputText setString:@""];
}

- (id)executeScript:(NSString *)script
{
    STEnvironment *env = [conversation context];
    NSString      *cmd;
    id             result = nil;

    /* FIXME: why? */

    cmd = [script stringByAppendingString:@" "];
    NS_DURING
        result = [conversation runScriptFromString:cmd];
    NS_HANDLER
        [self showException:localException];
    NS_ENDHANDLER

    [env setObject:script forName:@"LastCommand"];
    [env setObject:result forName:@"LastObject"];
    
    return result;
}

- (void)updateLanguage:(id)sender
{
    NSLog(@"Change language (not implemented).");
}

- (void)displayResult:(id)obj
{
    NSMutableString *result = [NSMutableString string];
    NSString        *className = NSStringFromClass([obj class]);
    int              i;
    
    if(obj)
    {
        if([obj isKindOfClass:[NSArray class]])
        {
            [result appendFormat:@"(%@)\n", className];
            
            for(i = 0; i<[obj count]; i++)
            {
                [result appendFormat:@"%i  %@\n", i, 
                       [self displayStringForObject:[obj objectAtIndex:i]]]; 
            }
            
        }
        else if([obj isKindOfClass:[NSSet class]])
        {
            [result appendFormat:@"(%@)\n", className];
            
            obj = [[obj allObjects] sortedArrayUsingSelector:@selector(compare:)];
            for(i = 0;i<[obj count]; i++)
            {
                [result appendFormat:@"%@\n", 
                       [self displayStringForObject:[obj objectAtIndex:i]]]; 
            }
            
        }
        else if([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *key;
            NSArray  *keys;
            
            [result appendFormat:@"(%@)\n", className];
            
            keys = [[obj allKeys] sortedArrayUsingSelector:@selector(compare:)];

            for(i = 0;i<[keys count]; i++)
            {
                key = [keys objectAtIndex:i];
                [result appendFormat:@"%@ : %@\n",  
                       [self displayStringForObject:key], 
                       [self displayStringForObject:[obj objectForKey:key]]]; 
            }   
        }
        else
        {
            [result appendFormat:@"%@\n", [self displayStringForObject:obj]];
        }
    }

    [result appendString:@"\n"];

    [self displayString:result attributes:outputAttributes];
}

- (NSString *)displayStringForObject:(id)object
{
    NSString *str = [object description];
        
    /* FIXME: be more intelligent */
    
    if( [str length] > 60 )
    {
        str = [str substringToIndex:60];
        str = [str stringByAppendingString:@"..."];
    }
    
    return str;
}
- (void)showException:(NSException *)exception
{
    NSString          *string;
    
    string = [NSString stringWithFormat:@"ERROR (%@): %@\n", 
                                [exception name],
                                [exception reason]];

    [self displayString:string attributes:errorAttributes];
}
- show:(id)string
{
    [self displayString:string attributes:outputAttributes];
}
- showLine:(id)string
{
    [self displayString:[NSString stringWithFormat:@"%@\n", string] 
             attributes:errorAttributes];
}

- (void)displayString:(NSString *)aString attributes:(NSDictionary *)attributes
{
    NSAttributedString *astring;

    astring = [[NSAttributedString alloc] initWithString:aString
                                              attributes:attributes];
    [dialogText insertText:AUTORELEASE(astring)];
}
- (void)complete:(id)sender
{
    // NSRange range = [inputText selectedRange];
    NSLog(@"complete %@", nil);
}
@end
