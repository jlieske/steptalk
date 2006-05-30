//
//  STTranscriptView.m
//  StepTalk
//
//  Created by Stefan Urbanek on 24.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "STTranscriptView.h"

NSString *STResultFormatting = @"STResultFormatting";
NSString *STScriptFormatting = @"STScriptFormatting";
NSString *STErrorFormatting = @"STErrorFormatting";
NSString *STDefaultFormatting = @"STDefaultFormatting";

@implementation STTranscriptView
- (void)initDefaultFormattings
{
    NSColorList *list;
    NSMutableDictionary *dict;
    NSDictionary        *atts;
    
    dict = [NSMutableDictionary dictionary];
    
    list = [NSColorList colorListNamed:@"Crayons"];
    
    atts = [[NSDictionary alloc] initWithObjectsAndKeys:
        [list colorWithKey:@"Mercury"], NSBackgroundColorAttributeName,
        nil, nil];
    
    [dict setObject:atts forKey:STScriptFormatting];
    
    atts = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSColor colorWithDeviceCyan:0.17 magenta:0.11 yellow:0.00 black:0 alpha:1],
        NSBackgroundColorAttributeName,
        nil, nil];
    [dict setObject:atts forKey:STResultFormatting];

    atts = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSColor colorWithDeviceCyan:0.00 magenta:0.27 yellow:0.05 black:0 alpha:1],
        NSBackgroundColorAttributeName,
        nil, nil];   
    [dict setObject:atts forKey:STErrorFormatting];

    atts = [[NSDictionary  alloc] initWithObjectsAndKeys:
        [NSColor whiteColor], NSBackgroundColorAttributeName,
        nil, nil];
    [dict setObject:atts forKey:STDefaultFormatting];

    formattings = [[NSDictionary alloc] initWithDictionary:dict];
}
- (void)clean:(id)sender
{
    [self setString:@""];
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
- (NSDictionary *)formattings {
    return [[formattings retain] autorelease];
}

- (void)setFormattings:(NSDictionary *)value {
    if (formattings != value) {
        [formattings release];
        formattings = [value copy];
    }
}

- (BOOL)showsTimestamp {
    return showsTimestamp;
}

- (void)setShowsTimestamp:(BOOL)value {
    if (showsTimestamp != value) {
        showsTimestamp = value;
    }
}

- (void)showFormat:(NSString*)format,...
{
    va_list   args;
    
    va_start(args, format);
    
    [self showFormat:format arguments:args];
}

- (void)showFormat:(NSString*)format arguments: (va_list)args

{
    NSString           *message;

    message = [[NSString alloc] initWithFormat: format arguments: args];
    message = [self formatString:message];
    
    [self displayString:[message autorelease] formatting:nil];
}
- (NSString *)formatString:(NSString *)aString
{
    NSString *timestamp;
    
    timestamp = [[NSCalendarDate date] descriptionWithCalendarFormat:@"%H:%M:%S"]; 
    
    if(showsTimestamp)
    {
        aString = [NSString stringWithFormat:@"%@\t%@\n",timestamp, aString];
    }
    else
    {
        aString = [NSString stringWithFormat:@"%@\n", aString];
    }
    
    return aString;
}
- (void)show:(id)anObject
{
    NSString *string = [self stringFromObject:anObject];
    [self displayString:string formatting:nil];
}
- (void)showLine:(id)anObject
{
    NSString *string;
    string = [[self stringFromObject:anObject] stringByAppendingString:@"\n"];
    [self displayString:string formatting:nil];
}
- (void)displayString:(NSString *)aString formatting:(NSString *)formatting
{
    NSDictionary *attributes;
    NSAttributedString *attstring;    
    NSRange             range;
    
    if(!aString)
        return;

    if(!formattings)
    {
        [self initDefaultFormattings];
    }
    
    if(formatting)
    {
        attributes = [formattings objectForKey:formatting];
    }
    else
    {
        attributes = [formattings objectForKey:STDefaultFormatting];
    }

    attstring = [[NSAttributedString alloc] initWithString:aString 
                                                    attributes:attributes];
    
    [[self textStorage] appendAttributedString:attstring];
    range = NSMakeRange([[self textStorage] length]-1,0);
    [self scrollRangeToVisible:range];
    [self setNeedsDisplay:YES];
    
    [attstring release];
}
- (NSString *)description
{
    return @"Transcript";
}
@end
