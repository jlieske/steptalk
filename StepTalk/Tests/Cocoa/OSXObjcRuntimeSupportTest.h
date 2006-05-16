/**
    OSXObjcRuntimeSupportTest

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/


#import <Foundation/Foundation.h>
#import <ObjcUnit/ObjcUnit.h>
#import "STCocoa.h"
#import "ObjcRuntimeSupport.h"

@interface OSXObjcRuntimeSupportTest : TestCase {
}
@end

@interface TestClass : NSObject {
}

- (id) methodWithArg1:(id)arg1 arg2:(id)arg2 arg3:(id)arg3 arg4:(id)arg4 arg5:(id)arg5;

@end