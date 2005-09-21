/* All Rights reserved */

#ifndef __STVIEW_H__
#define __STVIEW_H__

#include <AppKit/AppKit.h>
#include <StepTalk/StepTalk.h>
#include "StepTalkObject.h"

@interface StepTalkView : NSButton
{
	StepTalkObject* object;
}
- (NSImage*) imageForView;
- (void) addIVar: (NSString*) name;
- (void) renameIVar: (id) key to: (id) name;
- (void) removeIVar: (NSString*) name;
- (void) setIVar: (id) obj withName: (NSString*) name;
- (id) ivarWithName: (NSString*) name;
- (NSMutableArray*) variablesArray;
- (NSMutableDictionary*) variables;
- (void) setOutlets;
- (NSString*) script;
- (void) execute: (id) sender;
- (void) setScript: (NSString*) aScript;
@end

#endif
