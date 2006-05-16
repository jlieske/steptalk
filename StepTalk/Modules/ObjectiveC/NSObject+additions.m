/**
    NSObject+additions

    Copyright (c) 2002 Free Software Foundation
 
    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Jun 14
   
    This file is part of the StepTalk project.
 
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02111, USA.
 
 */

#import "NSObject+additions.h"

#import <Foundation/NSArray.h>
#import <StepTalk/ObjcRuntimeSupport.h>

static int VisitSelectorAndAddToArray(Class class, SEL selector, void* array)
{
   if (!array)
      return 0;
   [(NSMutableArray*)array addObject: NSStringFromSelector(selector)];
   return 1;
}

static NSArray *methods_for_class(Class class)
{
    NSMutableArray          *array = [NSMutableArray array];

    if(!class)
        return nil;
    
    ObjcIterateSelectors(class, NO, &VisitSelectorAndAddToArray, array);
    return [NSArray arrayWithArray:array];
}

static NSArray *ivars_for_class(Class class)
{
    NSMutableArray        *array;
    struct objc_ivar_list* ivars; 
    const char            *cname;
    int                    i;
    
    if(!class)
        return nil;
    
    array = [NSMutableArray array];
    
    ivars = class->ivars;

    if(ivars)
    {
        for(i=0;i<ivars->ivar_count;i++)
        {
            cname = ivars->ivar_list[i].ivar_name;
            [array addObject:[NSString stringWithCString:cname]];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

@implementation NSObject(ObjectiveCRuntime)
+ (NSArray *)instanceMethodNames
{
    return methods_for_class(self);
}

- (NSArray *)methodNames
{
    return [[[self class] instanceMethodNames] 
                            sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSArray *)methodNames
{
    return methods_for_class(ObjcClassGetMeta(self));
}

+ (NSArray *)instanceVariableNames
{
    return ivars_for_class(self);
}
@end
