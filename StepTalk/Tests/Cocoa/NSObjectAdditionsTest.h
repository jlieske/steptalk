/**
    NSObjectAdditionsTest

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/

#import <Foundation/Foundation.h>
#import <ObjcUnit/ObjcUnit.h>
#import "NSObject+CocoaAdditions.h"

@interface NSObjectAdditionsTest : TestCase {
}

- (void) unimplementedMethod: (id)someArg;
- (void) overideThisMethod: (id)someArg;

@end
