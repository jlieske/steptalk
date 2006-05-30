/*
 * Copyright (C) 2005  Stefan Kleine Stegemann
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "NSUserDefaults+CocoaAdditions.h"
#import <CoreServices/CoreServices.h>

static NSArray* userLanguages = nil;

@implementation NSUserDefaults (CocoaAdditions)

+ (NSArray*) userLanguages;
{
   if (!userLanguages) {
      // This gives us an array with all two-letter language codes
      // that are installed on the system.
      NSMutableArray* temp = [NSMutableArray arrayWithArray: [[self standardUserDefaults] stringArrayForKey: @"AppleLanguages"]];
      
      // From the GNUstep sources it follows that "English" is always
      // included in userLanguages. To be compatible we include it here
      // too.
      [temp addObject: @"English"];
      
      // Note that (according to the developer docs) Mac OS X supports
      // language names like "English", "French", ... only for backward
      // compatibility. I didn't find a function to get the language name
      // for a given two-letter code. Thus we stick with the two letter
      // codes (plus "English").
      
      // userLanguages should be immutable
      userLanguages = [[NSArray alloc] initWithArray: temp copyItems: YES];
   }

   return [userLanguages autorelease];
}

@end

