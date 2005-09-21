#include <StepTalkView/StepTalkClass.h>
#include "StepTalkConnectionInspector.h"

@implementation StepTalkConnectionInspector

- (void) setObject: (id)anObject
{
  if (anObject != nil) 
    {
      NSArray		*array;

      [super setObject: anObject];
      // DESTROY(currentConnector);
      RELEASE(connectors);

      /*
       * Create list of existing connections for selected object.
       */
      connectors = [NSMutableArray new];
      array = [[(id<IB>)NSApp activeDocument] connectorsForSource: object
	ofClass: [NSNibControlConnector class]];
      [connectors addObjectsFromArray: array];
      array = [[(id<IB>)NSApp activeDocument] connectorsForSource: object
	ofClass: [NSNibOutletConnector class]];
      [connectors addObjectsFromArray: array];

      RELEASE(outlets);
      //outlets = RETAIN([[(id<Gorm>)NSApp classManager] allOutletsForObject: object]); 
      outlets = [[(StepTalkClass*)[self object] outlets] retain];
      DESTROY(actions);

      [oldBrowser loadColumnZero];

      /*
       * See if we can do initial selection based on pre-existing connections.
       */
      if ([NSApp isConnecting] == YES)
	{
	  id dest = [currentConnector destination];
	  unsigned row;

	  for (row = 0; row < [connectors count]; row++)
	    {
	      id<IBConnectors>	con = [connectors objectAtIndex: row];

	      if ([con destination] == dest)
		{
		  ASSIGN(currentConnector, con);
		  [oldBrowser selectRow: row inColumn: 0];
		  break;
		}
	    }
	}

      [newBrowser loadColumnZero];
      if (currentConnector == nil)
	{
	  if ([connectors count] > 0)
	    {
	      currentConnector = RETAIN([connectors objectAtIndex: 0]);
	    }
	  else if ([outlets count] == 1)
	    {
	      [newBrowser selectRow: 0 inColumn: 0];
	      [newBrowser sendAction];
	    }
	}


      if ([currentConnector isKindOfClass: [NSNibControlConnector class]] == YES && 
	  [NSApp isConnecting] == NO)
	{
	  [newBrowser setPath: @"/target"];
	  [newBrowser sendAction];
	}

      [self updateButtons];
    }
}

@end
