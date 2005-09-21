/**
    ObjcRuntimeSupport
 
    Copyright (c) 2002 Free Software Foundation
 
    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL
 
    This file is part of the StepTalk project.
*/

#ifndef GNUSTEP
#import "STCocoa.h"
#endif
#import <Foundation/Foundation.h>
#import <objc/objc-api.h>

#ifndef GNUSTEP
#import "OSXObjcRuntime+Additions.h"
#import <objc/objc-class.h>
#import <objc/objc-runtime.h>
#endif

// Callbacks for iterator functions
typedef int (*VisitClassCallback)(Class clazz, void* userData);
typedef int (*VisitSelectorCallback)(Class clazz, SEL selector, void* userData);

void ObjcIterateClasses(VisitClassCallback callback, void* userData);
void ObjcIterateSelectors(Class clazz, BOOL includeMeta, VisitSelectorCallback callback, void* userData);

const char* ObjcClassName(Class class);
Class ObjcClassGetMeta(Class class);

SEL ObjcRegisterSel(const char* name, const char* types);
const char* ObjcSelName(SEL selector);
const char* ObjcSelGetType(SEL selector);

int ObjcSizeOfType(const char* type);
int ObjcAlignOfType(const char* type);
const char* ObjcSkipTypeSpec(const char* type);
const char* ObjcSkipArgSpec(const char* type);
