/**
    OSXObjcRuntimeSupport+Addtions

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/

/*
 * The following types are not defined by the OSX Objective-C
 * runtime. However, experiments with @encode have shown that
 * they are supported.
 */
#define _C_CONST      'r'
#define _C_LNG_LNG    'q'
#define _C_ULNG_LNG   'Q'
#define _C_BOOL       'B'
#define _C_IN         'n'
#define _C_INOUT      'N'
#define _C_OUT        'o'
#define _C_BYCOPY     'O'
#define _C_ONEWAY     'V'
