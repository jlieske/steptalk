/**
    GuileEngine
 
    Copyright (c) 2002 Free Software Foundation
 
    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Jan 13
 
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

#import "GuileEngine.h"

#import <ScriptKit/Guile.h>
#import <StepTalk/StepTalk.h>

#import <Foundation/NSDebug.h>

@class NSEnumerator;

int fake_guile_main(int argc, char **argv)
{
    NSString      *sourceCode = (NSString *)argv[1];
    STEnvironment *env        = (STEnvironment *)argv[2];
    GuileInterpreter *interp;
    GuileScript      *script;
    GuileSCM         *result;
    NSEnumerator     *e;
    id               *obj;
    
    gstep_init();
//    gstep_link_base();

    [GuileInterpreter initializeInterpreter];

    interp = AUTORELEASE([[GuileInterpreter alloc] init]);
    script = AUTORELEASE([[GuileScript alloc] init]);

    e = [[[env defaultObjectPool] allKeys] objectEnumerator];

    /* FIXME: If we do not remove these, we get an exception */
    [env removeObjectWithName:@"NSProxy"];
    [env removeObjectWithName:@"NSDistantObject"];
    [env addObject:env withName:@"Env"];
    [script setUserDictionary:[env defaultObjectPool]];
    [script setDelegate:sourceCode];
    result = [interp executeScript:script];
    
    /* FIXME: ignore result */
    
    return 0;
}


@implementation GuileEngine
- (BOOL)understandsCode:(NSString *)code
{
    NSLog(@"Do not know how to chceck if code is Guile.");
    return NO;
}

- (id) executeCode:(NSString *)sourceCode 
       inEnvironment:(STEnvironment *)env
{
    char *args[3];

    args[0] = "dummy";
    args[1] = (char *)sourceCode;
    args[2] = (char *)env;

    /* FIXME: ugly trick */
    gh_enter(3, args, fake_guile_main);
}
@end

