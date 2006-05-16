/**
    STCocoa

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/

#import "STCocoa.h"

NSArray* NSStandardLibraryPaths(void)
{
   return NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSAllDomainsMask, YES);
}

BOOL DebugSet(NSString* level)
{
   // TODO use a bit more sophisticated approach
#ifdef DEBUG
   return YES;
#else
   return NO;
#endif
}


