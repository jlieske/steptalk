//
//  ConversationDocument.m
//  StepTalking
//
//  Created by Stefan Urbanek on 14.5.2006.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.
//

#import "ConversationDocument.h"

#import <StepTalk/StepTalk.h>

#import <Transcript.h>

@implementation ConversationDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        NSColorList *list;
        NSDictionary *dict;
        
        environment = [STEnvironment environmentWithDefaultDescription];
        [environment retain];
        [environment setObject:environment forName:@"Environment"];
        
        conversation = [[STConversation alloc] initWithContext:environment
                                                      language:@"Smalltalk"];
        
        
        // NSLog(@"Conersation: %@", conversation);    
        // NSLog(@"Environment: %@", environment);    
        // NSLog(@"Language: %@", [conversation language]);    
        
        transcript = [[Transcript alloc] init];
        
        list = [NSColorList colorListNamed:@"Crayons"];
        
        scriptAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
            [list colorWithKey:@"Mercury"], NSBackgroundColorAttributeName,
            nil, nil];
        resultAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSColor colorWithDeviceCyan:0.17 magenta:0.11 yellow:0.00 black:0 alpha:1],
            NSBackgroundColorAttributeName,
            nil, nil];   
        errorAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSColor colorWithDeviceCyan:0.00 magenta:0.27 yellow:0.05 black:0 alpha:1],
            NSBackgroundColorAttributeName,
            nil, nil];   
        
        dict = [[NSDictionary  alloc] initWithObjectsAndKeys:
            [NSColor whiteColor], NSBackgroundColorAttributeName,
            nil, nil];
        
        [transcript setAttributes:[dict autorelease]];
        [environment setObject:transcript forName:@"Transcript"];

        historySize = 50;
        history = [[NSMutableArray alloc] init];
        //[history addObject:@"1 + 1"];
        //[history addObject:@"Transcript showLine:'Hi!'"];
    }
    return self;
}
- (IBAction)interpret:(id)sender
{
    [self interpretAndKeep:sender];
    
    [scriptEditor setString:@""];
}
- (IBAction)interpretAndKeep:(id)sender
{
    NSString *string;
    NSString *source;
    NSString *errorString;
    NSString *language;
    id        result;
    
    source = [scriptEditor string];
    [self saveInHistory:source];

    /* FIXME: hack */
    if(![source hasSuffix:@"\n"])
    {
        source = [source stringByAppendingString:@"\n"];
    }
    [transcript displayString:source withAttributes:scriptAttributes];

    /* Set the conversation language */
    
    language = [[languagesPopUp selectedItem] representedObject];
    [conversation setLanguage:language];
    
    /* Interpret the script and get the result */
    @try {
        [conversation interpretScript:source];
    }
    @catch (NSException *exception) {
        errorString = [NSString stringWithFormat:@"Exception: %@\nReason: %@\n",
            [exception name], [exception  reason]];
        [transcript displayString:errorString withAttributes:errorAttributes];
    }
    @finally {
        /* FIXME: Do nothing at the moment */
    }
    
    result = [conversation result];

    string = [transcript stringFromObject:result];
    string = [string stringByAppendingString:@"\n"];
    [transcript displayString:string withAttributes:resultAttributes];
}
-(void)saveInHistory:(NSString *)source
{
    int i;

    [history insertObject:[[source copy] autorelease] atIndex:0];
    historyPointer = 0;
    [currentScript release];
    currentScript = nil;
    
    while([history count] >= historySize)
    {
        [history removeLastObject];
    }
}
- (void)recallPreviousScript:(id)sender
{
    if(historyPointer >= historySize || historyPointer >= [history count])
    {
        return;
    }
    if(currentScript == 0)
    {
        currentScript = [[scriptEditor string] copy];

        [scriptEditor setString:[history objectAtIndex:historyPointer]];
    }
    else
    {
        if(historyPointer < historySize-1 && historyPointer < [history count]-1)
        {
            historyPointer = historyPointer + 1;
            [scriptEditor setString:[history objectAtIndex:historyPointer]];
        }
    }
    [scriptEditor setNeedsDisplay:YES];
}
- (void)recallNextScript:(id)sender
{
    if(historyPointer == 0 && currentScript != nil)
    {
        [scriptEditor setString:currentScript];
        [currentScript release];
        currentScript = 0;
    }
    else if(historyPointer > 0)
    {
        historyPointer = historyPointer - 1;
        [scriptEditor setString:[history objectAtIndex:historyPointer]];
    }
}

- (IBAction)cleanConversation:(id)sender
{
    [transcript clean:sender];
}

- (NSString *)windowNibName
{
    return @"ConversationDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];

    [transcript setTranscriptView:conversationView];
    [scriptEditor setDelegate:self];
    [self updateLanguages];
/*    
    [transcript displayString:@"This is script formatting\n" withAttributes:scriptAttributes];
    [transcript displayString:@"This is script output formatting\n" withAttributes:nil];
    [transcript displayString:@"This is script result formatting\n" withAttributes:resultAttributes];
*/
}
- (void)updateLanguages
{
    NSEnumerator   *enumerator;
    NSString       *language;
    id<NSMenuItem>  item;

    [languagesPopUp removeAllItems];
    
    enumerator = [[[STLanguageManager defaultManager] availableLanguages] objectEnumerator];
    
    while( (language = [enumerator nextObject]) )
    {
        [languagesPopUp addItemWithTitle:language];
        item = [languagesPopUp lastItem];
        [item setRepresentedObject:language];
    }
}
- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    
    // For applications targeted for Tiger or later systems, you should use the new Tiger API -dataOfType:error:.  In this case you can also choose to override -writeToURL:ofType:error:, -fileWrapperOfType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    
    // For applications targeted for Tiger or later systems, you should use the new Tiger API readFromData:ofType:error:.  In this case you can also choose to override -readFromURL:ofType:error: or -readFromFileWrapper:ofType:error: instead.
    
    return YES;
}

@end
