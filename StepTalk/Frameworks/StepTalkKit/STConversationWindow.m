//
//  STConversationWindow.m
//  StepTalk
//
//  Created by Stefan Urbanek on 24.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "STConversationWindow.h"

#import "STConversationController.h"
#import <StepTalk/StepTalk.h>
static NSImage *runImage = nil;
static NSImage *arrowUpImage = nil;
static NSImage *arrowDownImage = nil;
static NSImage *cleanImage = nil;

@implementation STConversationWindow
+ (void)initialize
{
    NSBundle *bundle;
    NSString *path;
    
    bundle = [NSBundle bundleForClass:[self class]];
    path = [bundle pathForImageResource:@"Run"];
    runImage = [[NSImage alloc] initByReferencingFile:path];
    path = [bundle pathForImageResource:@"arrowUp"];
    arrowUpImage = [[NSImage alloc] initByReferencingFile:path];
    path = [bundle pathForImageResource:@"arrowDown"];
    arrowDownImage = [[NSImage alloc] initByReferencingFile:path];
    path = [bundle pathForImageResource:@"clean"];
    cleanImage = [[NSImage alloc] initByReferencingFile:path];
}
- init
{
    self = [super initWithContentRect:NSMakeRect(300,400,400,300)
                            styleMask: NSTitledWindowMask 
        | NSClosableWindowMask 
        | NSMiniaturizableWindowMask 
        | NSResizableWindowMask
                              backing:  NSBackingStoreBuffered
                                defer:NO];

    [self initContents];
    return self;
}
- (void)initContents
{
    NSToolbar *toolbar;
    
    NSLog(@"Initializing contents of STConversationWindow");
    
    if(![NSBundle loadNibNamed:@"StepTalkConversation" owner:self])
    {
        [NSException raise:STInternalInconsistencyException
                    format:@"Unable to load StepTalk conversation panel resources"];
        return;
    }
    
    [self setContentView:_contents];
    [self setTitle:@"StepTalk Conversation"];

    languagesPopUp = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0,0,100,30)];
    [languagesPopUp setTarget:self];
    [languagesPopUp setAction:@selector(languageChanged:)];
    [self updateLanguages];
    [self languageChanged:nil];
    
    toolbar = [[NSToolbar alloc] initWithIdentifier:@"StepTalkConversation"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [self setToolbar:toolbar];
}
- (void)setContext:(STContext *)context
{
    [[conversationController conversation] setContext:context];
}
- (STContext *)context
{
    return [[conversationController conversation] context];
}

- (void)interpret:(id)sender
{
    NSString *script = [inputView script];

    [inputView cleanInputAndSaveHistory:self];
    [conversationController interpretScript:script];
}
- (void)interpretAndKeep:(id)sender
{
    NSString *script = [inputView script];
    
    [conversationController interpretScript:script];
}
- (void)cleanTranscript:(id)sender
{
    [transcript clean:sender];
}

-(void)languageChanged:(id)sender
{
    NSString *language;
    language = [[languagesPopUp selectedItem] representedObject];
    [conversationController setLanguage:language];
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
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:
        NSToolbarPrintItemIdentifier,
        NSToolbarCustomizeToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarSeparatorItemIdentifier, 
        @"Interpret",
        @"Languages",
        @"CleanTranscript",
        @"RecallPreviousScript",
        @"RecallNextScript",
        nil];
}
- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects:
        @"Interpret",
        @"Languages",
        NSToolbarSeparatorItemIdentifier, 
        @"RecallPreviousScript",
        @"RecallNextScript",
        NSToolbarSeparatorItemIdentifier, 
        @"CleanTranscript",
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarCustomizeToolbarItemIdentifier,
        nil];
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
     itemForItemIdentifier:(NSString *)identifier 
 willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item;
    
    item = [[[NSToolbarItem alloc] initWithItemIdentifier: identifier] autorelease];
    
    if([identifier isEqualToString:@"Interpret"])
    {
        [item setLabel:@"Interpret"];
        [item setToolTip:@"Interpret script"];
        [item setImage:runImage];
        [item setTarget:self];
        [item setAction:@selector(interpret:)];
    }
    else if([identifier isEqualToString:@"CleanTranscript"])
    {
        [item setLabel:@"Clean"];
        [item setToolTip:@"Clean transcript"];
        [item setImage:cleanImage];
        [item setTarget:transcript];
        [item setAction:@selector(clean:)];
    }
    else if([identifier isEqualToString:@"RecallPreviousScript"])
    {
        [item setLabel:@"Recall previous"];
        [item setToolTip:@"Recall previous script"];
        [item setImage:arrowUpImage];
        [item setTarget:inputView];
        [item setAction:@selector(recallPreviousScript:)];
    }
    else if([identifier isEqualToString:@"RecallNextScript"])
    {
        [item setLabel:@"Recall next"];
        [item setToolTip:@"Recall next script"];
        [item setImage:arrowDownImage];
        [item setTarget:inputView];
        [item setAction:@selector(recallNextScript:)];
    }
    else if([identifier isEqualToString:@"Languages"])
    {
        [item setView:languagesPopUp];
        [item setMinSize: NSMakeSize(70,32)];
        [item setMaxSize: NSMakeSize(200,32)];
        [item setToolTip:@"Script language"];
        [item setLabel:@"Language"];
    }
    
    return item;

}
@end
