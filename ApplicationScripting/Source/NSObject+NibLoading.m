/** NSObject+NibLoading

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 10
    
    This file is part of the StepTalk.
 
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.
 
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
*/

#import "NSObject+NibLoading.h"

#import <Foundation/NSBundle.h>
#import <Foundation/NSDictionary.h>

@implementation NSObject(AFNibLoading)
- (BOOL)loadMyNibNamed:(NSString *)aName
{
    NSDictionary *dict;
    NSBundle     *bundle;
    BOOL          flag;
    
    dict = [NSDictionary dictionaryWithObjectsAndKeys:self, @"NSOwner", 
                                                      nil, nil];

    bundle = [NSBundle bundleForClass:[self class]];
    
    flag = [bundle loadNibFile:aName
             externalNameTable:dict
                      withZone:[self zone]];

    if(!flag)
    {
        NSRunAlertPanel(@"Unable to load resources",
                        @"Unable to load '%@' resources",
                        @"Cancel", nil, nil, aName);

    }
    return flag;
}
@end

