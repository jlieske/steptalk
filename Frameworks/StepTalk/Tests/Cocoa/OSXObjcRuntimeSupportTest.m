/**
    OSXObjcRuntimeSupportTest

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/

#import "OSXObjcRuntimeSupportTest.h"
#import <MocKit/MockObject.h>
#import <objc/objc-class.h>

// Callback functions for ObjcRuntime
int CbAddClassNameToSet(Class clazz, void* set)
{
   if (!set)
      return 0;
   [(NSMutableSet*)set addObject: [NSString stringWithCString: ObjcClassName(clazz)]];
   //printf("%s\n", ObjcClassName(clazz));
   return 1;
}

int CbAddMethodSelectorToSet(Class clazz, SEL selector, void* set)
{
   if (!set)
      return 0;
   [(NSMutableSet*)set addObject: [NSString stringWithCString: ObjcSelName(selector)]];
   //printf("%s\n", ObjcSelName(selector));
   return 1;
}

union TestUnion {
   long long e1;
   struct {
      double e21;
      double e22;
   };
   int e3[2];
};

@implementation OSXObjcRuntimeSupportTest

- (void) setUp
{
}

- (void) tearDown
{
}

- (void) testClassNameReturnsName
{
   [self assertInt: strcmp(ObjcClassName([NSObject class]), "NSObject") equals: 0];
}

- (void) testFindsClassesOfKindNSObject
{
   NSMutableSet* classNames = [NSMutableSet set];
   ObjcIterateClasses(&CbAddClassNameToSet, classNames);
      
   [self assertTrue: [classNames containsObject: @"NSObject"] message: @"missing NSObject"];
   [self assertTrue: [classNames containsObject: @"NSString"] message: @"missing NSString"];
   [self assertTrue: [classNames containsObject: @"NSMutableDictionary"] message: @"missing NSMutableDictionary"];
   [self assertTrue: [classNames containsObject: @"TestClass"] message: @"missing TestClass"];
   [self assertFalse: [classNames containsObject: @"NSATSGlyphGenerator"] message: @"found deprecated class NSATSGlyphGenerator"];
}

- (void) testRegistersSelector
{
   [self assertTrue: ObjcRegisterSel("someMessageWithoutArg", NULL) != NULL];
   [self assertTrue: ObjcRegisterSel("someMessageWithArg:andArg:", NULL) != NULL];
   [self assertTrue: ObjcRegisterSel(NULL, NULL) == NULL];
   
   SEL selector = ObjcRegisterSel("aMethod", NULL);
   [self assertTrue: selector != NULL];
   [self assertTrue: ObjcRegisterSel("aMethod", NULL) == selector];
}

- (void) testGetsCorrectSelectorName
{
   const char* selectorName = "someMethodWithArg:andArg:";
   SEL selector = ObjcRegisterSel(selectorName, NULL);
   [self assertTrue: ObjcSelName(selector) != NULL];
   [self assertInt: strcmp(ObjcSelName(selector), selectorName) equals: 0];
   [self assertTrue: ObjcSelName(NULL) != NULL];
}

- (void) testMethodSignatureWithObjcTypesWorks
{
   NSMethodSignature* signature = [NSMethodSignature signatureWithObjCTypes: "@28@0:4@8@12@16@20@24"];
   [self assertNotNil: signature];
   [self assertInt: [signature numberOfArguments] equals: 7]; // 2 extra for self and _cmd
   
   NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
   NSString* arg1 = [NSString stringWithString: @"arg1"];
   NSString* arg2 = [NSString stringWithString: @"arg2"];
   NSString* arg3 = [NSString stringWithString: @"arg3"];
   NSString* arg4 = [NSString stringWithString: @"arg4"];
   NSString* arg5 = [NSString stringWithString: @"arg5"];
   [invocation setArgument: &arg1 atIndex: 2];
   [invocation setArgument: &arg2 atIndex: 3];
   [invocation setArgument: &arg3 atIndex: 4];
   [invocation setArgument: &arg4 atIndex: 5];
   [invocation setArgument: &arg5 atIndex: 6];
   [invocation setSelector: ObjcRegisterSel("methodWithArg1:arg2:arg3:arg4:arg5:", NULL)];

   id mock = [MockObject mockForClass: [TestClass class] testCase: self];
   [[[[mock expect: @selector(methodWithArg1:arg2:arg3:arg4:arg5:)]
      once]
      withArguments: [NSArray arrayWithObjects: [Arg equalTo: @"arg1"], [Arg equalTo: @"arg2"], [Arg equalTo: @"arg3"], [Arg equalTo: @"arg4"], [Arg equalTo: @"arg5"], nil]]
      willAlwaysReturn: [NSNumber numberWithInt: 42]];

   [invocation invokeWithTarget: mock];
   NSString* retVar = nil;
   [invocation getReturnValue: &retVar];

   [self assert: retVar equals: [NSNumber numberWithInt: 42]];
   [mock verify];
}

- (void) testFindsSelectorsForClass
{
   NSMutableSet* selectors = [NSMutableSet set];
   ObjcIterateSelectors([NSString class], NO, &CbAddMethodSelectorToSet, selectors);
   [self assertTrue: [selectors containsObject: @"length"] message: @"missing length selector"];
   [self assertFalse: [selectors containsObject: @"stringWithString:"] message: @"includes stringWithString: selector"];
}

- (void) testFindsSelectorsForClassAndMetaClass
{
   NSMutableSet* selectors = [NSMutableSet set];
   ObjcIterateSelectors([NSString class], YES, &CbAddMethodSelectorToSet, selectors);
   [self assertTrue: [selectors containsObject: @"length"] message: @"missing length selector"];
   [self assertTrue: [selectors containsObject: @"stringWithString:"] message: @"missing stringWithString: selector"];
}

- (void) testSkipScalarTypes
{
   [self assertTrue: ObjcSkipTypeSpec(NULL) == NULL message: @"skip NULL"];
   [self assertTrue: *ObjcSkipTypeSpec("fd") == 'd' message: @"skip float"];
   [self assertTrue: *ObjcSkipTypeSpec("d") == '\0' message: @"skip double"];
   const char* type = ObjcSkipTypeSpec("fd");
   [self assertTrue: *ObjcSkipTypeSpec(type) == '\0' message: @"skip to end"];
}

- (void) testSkipArrayTypes
{
   [self assertTrue: *ObjcSkipTypeSpec("[10i]d") == 'd' message: @"skip 1-dim array"];
   [self assertTrue: *ObjcSkipTypeSpec("[10[12d]]l") == 'l' message: @"skip 2-dim array"];
   [self assertTrue: *ObjcSkipTypeSpec("[10i]") == '\0' message: @"skip 1-dim array to end"];
   [self assertTrue: *ObjcSkipTypeSpec("[10[12d]]") == '\0' message: @"skip 2-dim array to end"];
}

- (void) testSkipPointerTypes
{
   [self assertTrue: *ObjcSkipTypeSpec("*l") == 'l' message: @"skip char pointer"];
   [self assertTrue: *ObjcSkipTypeSpec("^Ld") == 'd' message: @"skip simple pointer"];
   [self assertTrue: *ObjcSkipTypeSpec("^^Ld") == 'd' message: @"skip simple pointer to pointer"];
   [self assertTrue: *ObjcSkipTypeSpec("^[10l]d") == 'd' message: @"skip pointer to array"];
}

- (void) testSkipStructTypes
{
   [self assertTrue: *ObjcSkipTypeSpec("{Foo=id[12[42d]]*^i^^l}d") == 'd' message: @"skip structure"];
   [self assertTrue: *ObjcSkipTypeSpec("{}i") == 'i' message: @"skip empty struct"];
   [self assertTrue: *ObjcSkipTypeSpec(@encode(struct TestStruct)) == '\0' message: @"skip complex struct"];
}

- (void) testSkipUnionTypes
{
   [self assertTrue: *ObjcSkipTypeSpec("(Bar=i[4c])d") == 'd' message: @"skop union"];
   [self assertTrue: *ObjcSkipTypeSpec("()f") == 'f' message: @"skip empty union"];
   [self assertTrue: *ObjcSkipTypeSpec(@encode(union TestUnion)) == '\0' message: @"skip complex union"];
}

- (void) testSkipConstType
{
   [self assertTrue: *ObjcSkipTypeSpec("r{?=idfl}L") == 'L'];
}

- (void) testSizeOfScalarTypes
{
   //   printf("\n%s: %d\n", @encode(struct TestStruct), objc_sizeof_type(@encode(struct TestStruct)));
   //printf("\n%s\n", @encode(double*));
   [self assertInt: ObjcSizeOfType(@encode(float)) equals: sizeof(float) message: @"float"];
   [self assertInt: ObjcSizeOfType(@encode(double)) equals: sizeof(double) message: @"double"];
   [self assertInt: ObjcSizeOfType(@encode(int)) equals: sizeof(int) message: @"int"];
   [self assertInt: ObjcSizeOfType(@encode(unsigned int)) equals: sizeof(unsigned int) message: @"unsigned int"];
   [self assertInt: ObjcSizeOfType(@encode(long)) equals: sizeof(long) message: @"long"];
   [self assertInt: ObjcSizeOfType(@encode(unsigned long)) equals: sizeof(unsigned long) message: @"unsigned long"];
   [self assertInt: ObjcSizeOfType(@encode(long long)) equals: sizeof(long long) message: @"long long"];
   [self assertInt: ObjcSizeOfType(@encode(unsigned long long)) equals: sizeof(unsigned long long) message: @"unsigned long long"];
   [self assertInt: ObjcSizeOfType(@encode(short)) equals: sizeof(short) message: @"short"];
   [self assertInt: ObjcSizeOfType(@encode(unsigned short)) equals: sizeof(unsigned short) message: @"unsigned short"];
   [self assertInt: ObjcSizeOfType(@encode(char)) equals: sizeof(char) message: @"char"];
   [self assertInt: ObjcSizeOfType(@encode(unsigned char)) equals: sizeof(unsigned char) message: @"unsigned char"];
   [self assertInt: ObjcSizeOfType(@encode(void)) equals: sizeof(void) message: @"void"];
   [self assertInt: ObjcSizeOfType(@encode(id)) equals: sizeof(id) message: @"id"];
   [self assertInt: ObjcSizeOfType(@encode(SEL)) equals: sizeof(SEL) message: @"SEL"];
   [self assertInt: ObjcSizeOfType(@encode(Class)) equals: sizeof(Class) message: @"Class"];
   [self assertInt: ObjcSizeOfType(@encode(char*)) equals: sizeof(char*) message: @"char*"];
   [self assertInt: ObjcSizeOfType(@encode(void*)) equals: sizeof(void*) message: @"pointer"];
   
   //   [self assertInt: ObjcSizeOfType(@encode()) equals: sizeof() message: @""];
}

- (void) testSizeOfArrayTypes
{
   [self assertInt: ObjcSizeOfType(@encode(int[8])) equals: sizeof(int[8]) message: @"int[8]"];
   [self assertInt: ObjcSizeOfType(@encode(int[8][15])) equals: sizeof(int[8][15]) message: @"int[8][15]"];
}

- (void) testSizeOfStructTypes
{
   [self assertInt: ObjcSizeOfType(@encode(NSRect)) equals: sizeof(NSRect) message: @"NSRect"];
   [self assertInt: ObjcSizeOfType(@encode(NSSize)) equals: sizeof(NSSize) message: @"NSSize"];
   [self assertInt: ObjcSizeOfType(@encode(NSPoint)) equals: sizeof(NSPoint) message: @"NSPoint"];
   [self assertInt: ObjcSizeOfType(@encode(NSRange)) equals: sizeof(NSRange) message: @"NSRange"];
}

- (void) testSizeOfUnionTypes
{
   [self assertInt: ObjcSizeOfType(@encode(union TestUnion)) equals: sizeof(union TestUnion) message: @"TestUnion"];
}

- (void) testSizeOfConstTypes
{
   [self assertInt: ObjcSizeOfType(@encode(const char)) equals: sizeof(const char)];
}

- (void) testAlignOfScalarTypes
{
   [self assertInt: ObjcAlignOfType(@encode(float)) equals: __alignof__(float) message: @"float"];
   [self assertInt: ObjcAlignOfType(@encode(double)) equals: __alignof__(double) message: @"double"];
   [self assertInt: ObjcAlignOfType(@encode(int)) equals: __alignof__(int) message: @"int"];
   [self assertInt: ObjcAlignOfType(@encode(unsigned int)) equals: __alignof__(unsigned int) message: @"unsigned int"];
   [self assertInt: ObjcAlignOfType(@encode(long)) equals: __alignof__(long) message: @"long"];
   [self assertInt: ObjcAlignOfType(@encode(unsigned long)) equals: __alignof__(unsigned long) message: @"unsigned long"];
   [self assertInt: ObjcAlignOfType(@encode(long long)) equals: __alignof__(long long) message: @"long long"];
   [self assertInt: ObjcAlignOfType(@encode(unsigned long long)) equals: __alignof__(unsigned long long) message: @"unsigned long long"];
   [self assertInt: ObjcAlignOfType(@encode(short)) equals: __alignof__(short) message: @"short"];
   [self assertInt: ObjcAlignOfType(@encode(unsigned short)) equals: __alignof__(unsigned short) message: @"unsigned short"];
   [self assertInt: ObjcAlignOfType(@encode(char)) equals: __alignof__(char) message: @"char"];
   [self assertInt: ObjcAlignOfType(@encode(unsigned char)) equals: __alignof__(unsigned char) message: @"unsigned char"];
   [self assertInt: ObjcAlignOfType(@encode(void)) equals: __alignof__(void) message: @"void"];
   [self assertInt: ObjcAlignOfType(@encode(id)) equals: __alignof__(id) message: @"id"];
   [self assertInt: ObjcAlignOfType(@encode(SEL)) equals: __alignof__(SEL) message: @"SEL"];
   [self assertInt: ObjcAlignOfType(@encode(Class)) equals: __alignof__(Class) message: @"Class"];
   [self assertInt: ObjcAlignOfType(@encode(char*)) equals: __alignof__(char*) message: @"char*"];
   [self assertInt: ObjcAlignOfType(@encode(void*)) equals: __alignof__(void*) message: @"pointer"];
}

- (void) testAlignOfArrayTypes
{
   [self assertInt: ObjcAlignOfType(@encode(int[8])) equals: __alignof__(int[8]) message: @"int[8]"];
   [self assertInt: ObjcAlignOfType(@encode(double[8][15])) equals: __alignof__(double[8][15]) message: @"int[8][15]"];
}

- (void) testAlignOfStructTypes
{
   [self assertInt: ObjcAlignOfType(@encode(NSRect)) equals: __alignof__(NSRect) message: @"NSRect"];
   [self assertInt: ObjcAlignOfType(@encode(NSSize)) equals: __alignof__(NSSize) message: @"NSSize"];
   [self assertInt: ObjcAlignOfType(@encode(NSPoint)) equals: __alignof__(NSPoint) message: @"NSPoint"];
   [self assertInt: ObjcAlignOfType(@encode(NSRange)) equals: __alignof__(NSRange) message: @"NSRange"];
}

- (void) testAlignOfUnionTypes
{
   [self assertInt: ObjcAlignOfType(@encode(union TestUnion)) equals: __alignof__(union TestUnion) message: @"TestUnion"];
}

@end


@implementation TestClass

- (id) methodWithArg1:(id)arg1 arg2:(id)arg2 arg3:(id)arg3 arg4:(id)arg4 arg5:(id)arg5;
{
   return nil;
}

@end
