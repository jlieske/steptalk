//
//  STTranscriptView.h
//  StepTalk
//
//  Created by Stefan Urbanek on 24.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *STResultFormatting;
extern NSString *STScriptFormatting;
extern NSString *STErrorFormatting;
extern NSString *STDefaultFormatting;

@interface STTranscriptView : NSTextView {
    NSDictionary *formattings;
    BOOL showsTimestamp;
}
- (NSDictionary *)formattings;
- (void)setFormattings:(NSDictionary *)value;

- (BOOL)showsTimestamp;
- (void)setShowsTimestamp:(BOOL)value;

- (void)showFormat:(NSString*)format,...;
- (void)showFormat:(NSString*)format arguments: (va_list)args;

- (void)show:(id)anObject;
- (void)showLine:(id)anObject;

- (NSString *)stringFromObject:(id)anObject;

- (NSString *)formatString:(NSString *)aString;
- (void)displayString:(NSString *)aString formatting:(NSString *)formatting;
@end

