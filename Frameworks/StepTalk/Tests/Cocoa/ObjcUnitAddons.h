/**
    ObjcUnitAddons

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    
    Use/modify where and how you like. This file is distributed
    without any warranty. 
*/

#import <Foundation/Foundation.h>
#import <ObjcUnit/ObjcUnit.h>

#define ShouldRaise(block, exception) \
   NS_DURING \
      block; \
      [self fail: [NSString stringWithFormat: @"exception %@ expected", exception]];\
   NS_HANDLER \
      if ([localException isKindOfClass: [AssertionFailedException class]]) \
         [localException raise]; \
      [self assert: [localException name] equals: exception]; \
   NS_ENDHANDLER

#define ShouldRaiseExceptionWithMessage(block, exception, message) \
   NS_DURING \
      block; \
      [self fail: [NSString stringWithFormat: @"exception %@ expected", exception]];\
   NS_HANDLER \
      if ([localException isKindOfClass: [AssertionFailedException class]]) \
         [localException raise]; \
      [self assert: [localException name] equals: exception]; \
      [self assert: [localException reason] equals: message]; \
   NS_ENDHANDLER

#define ShouldNotRaise(block, exception) \
   NS_DURING \
      block; \
   NS_HANDLER \
      if ([[localException name] isEqualToString: exception]) \
         [self fail: [NSString stringWithFormat: @"exception %@ raised but was not expected", exception]]; \
      [localException raise]; \
   NS_ENDHANDLER

#define ShouldNotRaiseAnyException(block) \
   NS_DURING \
      block; \
   NS_HANDLER \
      [self fail: [NSString stringWithFormat: @"exception %@ was not expected", [localException name]]]; \
   NS_ENDHANDLER
