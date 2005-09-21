/* All Rights reserved */

#ifndef __STMETHOD_H__
#define __STMETHOD_H__

#include <AppKit/AppKit.h>
#include <StepTalk/StepTalk.h>
#include "StepTalkMetadatas.h"

@interface StepTalkMethod : NSObject
{
	NSString* name;
	NSMutableString* signature;
	NSMutableArray* arguments;
	NSString* content;
	NSString* returnType;
	StepTalkMetadatas* metadatas;
}

- (NSString*) description;
- (void) setName: (NSString*) aName;
- (void) addArgument: (NSString*) anArgument;
- (void) setContent: (NSString*) aContent;
- (void) setReturnType: (NSString*) aType; 

- (NSString*) name; 
- (NSArray*) arguments; 
- (NSString*) argumentAtIndex: (int) index;
- (NSString*) content; 
- (NSString*) signature; 
- (NSString*) returnType; 
- (StepTalkMetadatas*) metadatas; 

- (int) numberOfArguments; 

- (void) parseMethodName;

- (void) error: (NSException*) exc;
- (id) executeWithDictionary: (NSMutableDictionary*) variables andArguments: (NSArray*) args;
- (id) executeWithDictionary: (NSMutableDictionary*) variables;
@end

#endif
