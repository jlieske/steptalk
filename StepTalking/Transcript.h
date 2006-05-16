//
//  Transcript.h
//  StepTalkTest
//
//  Created by Stefan Urbanek on 1.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Transcript : NSObject {
    NSTextView *transcriptView;
    NSDictionary *attributes;
}
- (void)setTranscriptView:(NSTextView *)view;
- (void)clean:(id)sender;

- (void)show:(id)anObject;
- (void)showLine:(id)anObject;
- (void)displayString:(NSString *)aString withAttributes:(NSDictionary *)atts;
@end
