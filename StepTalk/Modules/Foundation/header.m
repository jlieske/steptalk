/**
    @@NAME@@.m x
 
    NOTE: Do not edit this file, it is automaticaly generated.
 
    Copyright (c) 2002 Free Software Foundation
 
    This file is part of the StepTalk project.
 
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

#import <Foundation/Foundation.h>

NSDictionary *STGet@@NAME@@(void)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    Class numberClass = [NSNumber class];
    IMP numberWithInt;
    IMP numberWithFloat;
    IMP setObject_forKey;

    SEL numberWithInt_sel = @selector(numberWithInt:);
    SEL numberWithFloat_sel = @selector(numberWithFloat:);
    SEL setObject_forKey_sel = @selector(setObject:forKey:);

    numberWithInt = [NSNumber methodForSelector:numberWithInt_sel];
    numberWithFloat = [NSNumber methodForSelector:numberWithFloat_sel];
    setObject_forKey = [dict methodForSelector:setObject_forKey_sel];

#define ADD_id_OBJECT(obj, name) \
            setObject_forKey(dict, setObject_forKey_sel, obj, name)

#define ADD_int_OBJECT(obj, name) \
            setObject_forKey(dict, setObject_forKey_sel, \
                            numberWithInt(numberClass, numberWithInt_sel, obj), \
                            name)

#define ADD_float_OBJECT(obj, name) \
            setObject_forKey(dict, setObject_forKey_sel, \
                            numberWithFloat(numberClass, numberWithInt_sel, obj), \
                            name)

#define ADD_NSPoint_OBJECT(obj, name) \
            setObject_forKey(dict, setObject_forKey_sel, \
                            [NSValue valueWithPoint:obj], \
                            name)

#define ADD_NSRange_OBJECT(obj, name) \
            setObject_forKey(dict, setObject_forKey_sel, \
                            [NSValue valueWithRange:obj], \
                            name)

#define ADD_NSSize_OBJECT(obj, name) \
            setObject_forKey(dict, setObject_forKey_sel, \
                            [NSValue valueWithSize:obj], \
                            name)

#define ADD_NSRect_OBJECT(obj, name) \
            setObject_forKey(dict, setObject_forKey_sel, \
                            [NSValue valueWithRect:obj], \
                            name)
