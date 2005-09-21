/* All Rights reserved */

#ifndef __STOBJECT_H__
#define __STOBJECT_H__

#include <AppKit/AppKit.h>
#include <StepTalk/StepTalk.h>

@interface StepTalkObject : NSObject
{
	NSString* script;
	NSMutableDictionary* variables;
	NSString* title;
}
- (NSString*) findOutlet: (NSString*) sel;
- (void) setTitle: (NSString*) title;
- (NSString*) title;
- (void) addIVar: (NSString*) name;
- (void) removeIVar: (NSString*) name;
- (void) renameIVar: (id) key to: (id) name;
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
