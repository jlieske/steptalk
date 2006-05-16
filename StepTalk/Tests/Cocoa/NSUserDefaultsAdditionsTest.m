/**
    NSUserDefaultsAdditionsTest

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/

#import "NSUserDefaultsAdditionsTest.h"

@implementation NSUserDefaultsAdditionsTest

- (void) setUp
{
}

- (void) tearDown
{
}

- (void) testReturnsValidUserLanguages
{
   NSArray* languages = [NSUserDefaults userLanguages];
   [self assertNotNil: languages];
   [self assert: languages same: [NSUserDefaults userLanguages]];
   [self assertTrue: [languages count] > 0];
   [self assertTrue: [languages containsObject: @"English"]];
}

@end
