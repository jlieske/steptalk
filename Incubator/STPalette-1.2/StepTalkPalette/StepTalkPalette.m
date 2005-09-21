/* All Rights reserved */

#include <AppKit/AppKit.h>
#include <StepTalkView/StepTalkView.h>
#include <StepTalkView/StepTalkObject.h>
#include <StepTalkView/StepTalkClass.h>
#include <GNUstepBase/GSObjCRuntime.h>
#include "StepTalkPalette.h"

static NSImage* image = nil;
static NSImage* imageView = nil;

@implementation NSApplication (nico)
- (BOOL) sendAction: (SEL)aSelector to: (id)aTarget from: (id)sender
{
  id resp = [self targetForAction: aSelector to: aTarget from: sender];

  if (resp != nil)
    {
      NSInvocation	*inv;
      NSMethodSignature	*sig;

      sig = [resp methodSignatureForSelector: aSelector];
      inv = [NSInvocation invocationWithMethodSignature: sig];
      [inv setSelector: aSelector];
      if ([sig numberOfArguments] > 2)
	{
	  [inv setArgument: &sender atIndex: 2];
	}
      [inv invokeWithTarget: resp];
      return YES;
    }

  return NO;
}
@end


@implementation StepTalkView (StepTalkPaletteInspector)

- (NSString *) connectInspectorClassName
{
	return @"StepTalkConnectionInspector";
}

- (NSString *) inspectorClassName
{
	return @"StepTalkInspector";
}

- (NSImage*) imageForView
{
	return image;
}

@end

@implementation StepTalkObject (StepTalkPalette)

- (NSString *) connectInspectorClassName
{
	return @"StepTalkConnectionInspector";
}

- (NSString *) inspectorClassName
{
	return @"StepTalkInspector";
}

@end

@implementation StepTalkClass (StepTalkPalette)

- (NSString *) connectInspectorClassName
{
	return @"StepTalkConnectionInspector";
}

- (NSString *) inspectorClassName
{
	return @"StepTalkClassInspector";
}

@end

@implementation StepTalkMethod (StepTalkPalette)

- (void) error: (NSException*) exc
{
	NSString* title = [NSString stringWithFormat: @"Exception %@ in method %@", 
		[exc name], signature];
	NSRunAlertPanel (title, [exc reason], @"Ok", NULL, NULL);
}

@end

@implementation StepTalkPalette

+ (void) initialize
{
	if (self == [StepTalkPalette class])
	{
		NSBundle* bundle = [NSBundle bundleForClass: [self class]];
		NSString* path = [bundle pathForImageResource: @"StepTalkIcon.png"];
		image = [[NSImage alloc] initWithContentsOfFile: path];
		NSString* path2 = [bundle pathForImageResource: @"StepTalkViewIcon.png"];
		imageView = [[NSImage alloc] initWithContentsOfFile: path];
	}
}

- (void) finishInstantiate
{
	id obj1 = [StepTalkObject new];

	// associate the actual object with it's graphical representation.
	[buttonSTObject setImage: image];
	[self associateObject: obj1
		type: IBObjectPboardType
		with: buttonSTObject];

	//id obj2 = [[StepTalkClass alloc] initWithName: @"MyClass"];
	id obj2 = [StepTalkClass new];

	// associate the actual object with it's graphical representation.
	[buttonSTClass setImage: image];
	[self associateObject: obj2
		type: IBObjectPboardType
		with: buttonSTClass];
}
	
@end
