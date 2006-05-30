//
//  ConversationDocument.m
//  StepTalking
//
//  Created by Stefan Urbanek on 14.5.2006.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.
//

#import "ConversationDocument.h"

#import <StepTalkKit/StepTalkKit.h>


@implementation ConversationDocument

- (id)init
{
    self = [super init];
    if (self) {
    
    }
    return self;
}

- (void)makeWindowControllers
{
    NSWindowController   *controller;
    STConversationWindow *window;

    window = [[STConversationWindow alloc] init];
    [window autorelease];
    controller = [[NSWindowController alloc] initWithWindow:window];

    [self addWindowController:controller];
}

/*
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
*/
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
