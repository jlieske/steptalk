/* All Rights reserved */

#include "StepTalkMetadatas.h"

@implementation StepTalkMetadatas

- (void) encodeWithCoder: (NSCoder*) coder
{
	//[super encodeWithCoder: coder];
	[coder encodeObject: tags];
	[coder encodeObject: documentation];
}

- (id) initWithCoder: (NSCoder*) coder
{
	//if (self = [super initWithCoder: coder]) 
	{
		ASSIGN (tags, [coder decodeObject]);
		ASSIGN (documentation, [coder decodeObject]);
	}
	return self;
}

- (id) init 
{
	if (self = [super init])
	{
		tags = [NSMutableDictionary new];
	}
	return self;
}

- (void) dealloc {
	[tags release];
	[documentation release];
	[super dealloc];
}

- (NSMutableDictionary*) tags { return tags; }
- (void) addTag: (id) tag value: (id) value { [tags setObject: value forKey: tag]; }
- (id) tag: (id) tag { return [tags objectForKey: tag]; }

- (void) setDocumentation: (NSString*) doc { ASSIGN(documentation, doc); }
- (NSString*) documentation { return documentation; }

@end
