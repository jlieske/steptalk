/* All Rights reserved */

#ifndef __STCLASS_H__
#define __STCLASS_H__

#include <AppKit/AppKit.h>
#include <StepTalk/StepTalk.h>

#include "StepTalkMethod.h"
#include "StepTalkRuntime.h"
#include "StepTalkMetadatas.h"


@interface StepTalkClass : NSObject
{
	NSMutableDictionary* variables;
	NSMutableDictionary* methods;
	NSString* name;
	id superClass;
	
	StepTalkMetadatas* metadatas;
}
- (id) initWithName: (NSString*) aName;
- (id) initWithName: (NSString*) aName parent: (NSString*) parentName;
- (StepTalkMetadatas*) metadatas;
- (BOOL) registerClass;
- (void) addIvarsFromSuperclass;
- (void) setName: (NSString*) aName;
- (NSString*) name;
- (id) superClass;
- (void) setParent: (NSString*) aName;
- (void) addMethod: (NSString*) methodName withContent: (NSString*) content;
- (void) addMethod: (NSString*) methodName withContent: (NSString*) content
	returnType: (NSString*) returnType;
- (void) removeMethod: (NSString*) methodName;
- (void) checkReturnType: (StepTalkMethod*) method;
- (StepTalkMethod*) getMethod: (NSString*) signature;
- (id) invocationOfMethod: (NSString*) methodSignature withArguments: (NSArray*) args inClass: (id) class
	returnType: (NSString**) type;
- (void) forwardInvocation: (NSInvocation*) anInvocation;
- (NSMethodSignature*) methodSignatureForSelector: (SEL) aSelector;
- (void) addIvar: (NSString*) aName withValue: (id) aValue;
- (void) removeIvar: (NSString*) aName;
- (id) setIvar: (NSString*) aName withValue: (id) aValue;
- (void) renameMethod: (id) key to: (id) aName;
- (void) renameIvar: (id) key to: (id) aName;
- (id) ivarWithName: (NSString*) aName;
- (void) addIvar: (NSString*) aName;
- (NSMutableDictionary*) variables; 
- (NSMutableArray*) variablesArray; 
- (NSMutableArray*) methodsArray;
- (SEL) getSelectorFromMethod: (NSString*) method;
- (NSMutableArray*) outlets;
- (NSMutableArray*) actions; 
- (NSString*) findOutlet: (NSString*) sel;
- (void) setActions;
- (void) setOutlets;
@end

#endif
