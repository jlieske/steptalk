//
//  Transcript.m
//  StepTalkTest
//
//  Created by Stefan Urbanek on 1.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Transcript.h"


@implementation Transcript
- (void)setTranscriptView:(NSTextView *)view
{
    [view retain];
    [transcriptView release];
    transcriptView = view;
}
- (void)setAttributes:(NSDictionary *)dict
{
    [dict retain];
    [attributes release];
    attributes = dict;
}
- (void)clean:(id)sender
{
    [transcriptView setString:@""];
}
- (NSString *)stringFromObject:(id)anObject
{
    NSString *string = nil;
    
    if( [anObject isKindOfClass:[NSString class]] )
    {
        string = anObject;
    }
    else if ( [anObject isKindOfClass:[NSNumber class]] )
    {
        string = [anObject stringValue];
    }
    else if( anObject != nil )
    {
        string = [anObject description];
    }

    return string;
}
- (void)show:(id)anObject
{
    NSString *string = [self stringFromObject:anObject];
    [self displayString:string withAttributes:nil];
}
- (void)showLine:(id)anObject
{
    NSString *string;
    string = [[self stringFromObject:anObject] stringByAppendingString:@"\n"];
    [self displayString:string withAttributes:nil];
}
- (void)displayString:(NSString *)aString withAttributes:(NSDictionary *)atts
{
    NSAttributedString *attstring;    
    NSRange             range;
    
    if(!aString)
        return;
    
    if(!atts)
    {
        attstring = [[NSAttributedString alloc] initWithString:aString 
                                                    attributes:attributes];
    }
    else
    {
        attstring = [[NSAttributedString alloc] initWithString:aString 
                                                    attributes:atts];
    }

    [[transcriptView textStorage] appendAttributedString:attstring];
    range = NSMakeRange([[transcriptView textStorage] length]-1,0);
    [transcriptView scrollRangeToVisible:range];
    [transcriptView setNeedsDisplay:YES];
    
    [attstring release];
}
@end
