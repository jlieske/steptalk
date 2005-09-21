/**
    AllTests

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/

#import "AllTests.h"
#import "NSObjectAdditionsTest.h"
#import "NSUserDefaultsAdditionsTest.h"
#import "OSXObjcRuntimeSupportTest.h"

@implementation AllTests

+ (TestSuite*) suite
{ 
   TestSuite *suite = [TestSuite suiteWithName: @"StepTalk/Cocoa Tests"]; 

   // Add your tests here ... 
   [suite addTest: [TestSuite suiteWithClass: [NSObjectAdditionsTest class]]];
   [suite addTest: [TestSuite suiteWithClass: [NSUserDefaultsAdditionsTest class]]];
   [suite addTest: [TestSuite suiteWithClass: [OSXObjcRuntimeSupportTest class]]];

   return suite;
}

@end

int main( int argc, const char * argv[])
{
    TestRunnerMain([AllTests class]); 
    return 0; 
}

