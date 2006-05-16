/**
    NSObjectAdditionsTest

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/

#import "NSObjectAdditionsTest.h"
#import "ObjcUnitAddons.h"

@implementation NSObjectAdditionsTest

- (void) setUp
{
}

- (void) tearDown
{
}

- (void) testInstanceSupportsNotImplementedError
{
   ShouldRaiseExceptionWithMessage([self unimplementedMethod: @"foo"], NSGenericException, @"method unimplementedMethod: not implemented in NSObjectAdditionsTest");
}

- (void) testInstanceSupportsSubclassResponsibilityError
{
   ShouldRaiseExceptionWithMessage([self overideThisMethod: @"foo"], NSGenericException, @"subclass NSObjectAdditionsTest should override overideThisMethod:");
}

- (void) unimplementedMethod: (id)someArg;
{
   [self notImplemented: _cmd];
}

- (void) overideThisMethod: (id)someArg;
{
   [self subclassResponsibility: _cmd];
}

@end
