/**
    STScriptsManager
  
    Copyright (c)2002 Stefan Urbanek
  
    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Mar 10
 
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

#import "STScriptsManager.h"

#import "STExterns.h"
#import "STLanguage.h"
#import "STFileScript.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>

static STScriptsManager *sharedScriptsManager = nil;

@interface STScriptsManager (STPriavteMethods)
- (NSArray *)_scriptsAtPath:(NSString *)path;
@end

@implementation STScriptsManager

/** Return default domain name for scripts. Usually this is application or
process name.*/
+ (NSString *)defaultScriptsDomainName
{
    return [[NSProcessInfo processInfo] processName];
}

/** Returns default scripts manager for current process (application or tool). */
+ defaultManager
{
    if(!sharedScriptsManager)
    {
        sharedScriptsManager = [[STScriptsManager alloc] init];
    }
    
    return sharedScriptsManager;
}

- init
{
    return [self initWithDomainName:nil];
}

/**
    Initializes the receiver to be used with domain named <var>name</var>.
    If <var>name</var> is nil, default scripts domain name will be used.
    
    <init />
*/
- initWithDomainName:(NSString *)name
{
    self = [super init];
    
    if(!name)
    {
        name = [STScriptsManager defaultScriptsDomainName];
    }
    
    scriptsDomainName = RETAIN(name);

    return self;
}

- (void)dealloc
{
    RELEASE(scriptsDomainName);
    [super dealloc];
}


/** Return name of script manager domain. */
- (NSString *)scriptsDomainName
{
    return scriptsDomainName;
}

/* Sets script search paths to defaults. Default paths are (in this order): 
   <gnustep library paths>/StepTalk/Scripts/<domain name>.
   <gnustep library paths>/StepTalk/Scripts/Shared and
   paths to Resource/Scripts in all loaded bundles including the main bundle.*/

- (void)setScriptSearchPathsToDefaults
{
    NSMutableArray *scriptPaths = [NSMutableArray array];
    NSEnumerator   *enumerator;
    NSString       *path;
    NSString       *str;
    NSArray        *paths;
    NSBundle       *bundle;
      
    paths = NSStandardLibraryPaths();

    enumerator = [paths objectEnumerator];

    while( (path = [enumerator nextObject]) )
    {
        path = [path stringByAppendingPathComponent:STLibraryDirectory];
        path = [path stringByAppendingPathComponent:@"Scripts"];

        str = [path stringByAppendingPathComponent: scriptsDomainName];
        [scriptPaths addObject:str];

        str = [path stringByAppendingPathComponent:@"Shared"];
        [scriptPaths addObject:str];
    }

    /* Add same, but without StepTalk (only Library/Scripts) */
    enumerator = [paths objectEnumerator];

    while( (path = [enumerator nextObject]) )
    {
        path = [path stringByAppendingPathComponent:@"Scripts"];

        str = [path stringByAppendingPathComponent: scriptsDomainName];
        [scriptPaths addObject:str];

        str = [path stringByAppendingPathComponent:@"Shared"];
        [scriptPaths addObject:str];
    }
    
    enumerator = [[NSBundle allBundles] objectEnumerator];

    while( (bundle = [enumerator nextObject]) )
    {
        path = [bundle resourcePath];
        path = [path stringByAppendingPathComponent:@"Scripts"];
        [scriptPaths addObject:path];
    }

    RELEASE(scriptSearchPaths);
    scriptSearchPaths = [[NSArray alloc] initWithArray:scriptPaths];
}

/**
    Retrun an array of script search paths. Scripts are searched 
    in Library/StepTalk/Scripts/<var>scriptsDomainName</var>, 
    Library/StepTalk/Scripts/Shared and in all loaded bundles in 
    <var>bundlePath</var>/Resources/Scripts.
*/

- (NSArray *)scriptSearchPaths
{
    if(!scriptSearchPaths)
    {
        [self setScriptSearchPathsToDefaults];
    }
    
    return scriptSearchPaths;
}

/** Set script search paths to <var>anArray</var>. */
- (void)setScriptSearchPaths:(NSArray *)anArray
{
    ASSIGN(scriptSearchPaths, anArray);
}

/** Return script search paths that are valid. That means that path exists and
    is a directory. */
- (NSArray *)validScriptSearchPaths
{
    NSMutableArray *scriptPaths = [NSMutableArray array];
    NSFileManager  *manager = [NSFileManager defaultManager];
    NSEnumerator   *enumerator;
    NSString       *path;
    NSArray        *paths;
    BOOL            isDir;
 
    paths = [self scriptSearchPaths];
    
    enumerator = [paths objectEnumerator];

    while( (path = [enumerator nextObject]) )
    {
        if( [manager fileExistsAtPath:path isDirectory:&isDir] && isDir )
        {
            // NSLog(@"VARLIOD %@", path);
            [scriptPaths addObject:path];
        }
    }

    return [NSArray arrayWithArray:scriptPaths];
}

/**
    Get a script with name <var>aString</var> for current scripting domain. 
*/
- (STFileScript *)scriptWithName:(NSString*)aString
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator  *pEnumerator;
    NSEnumerator  *sEnumerator;
    NSString      *path;
    NSString      *file;
    NSString      *str;
    NSArray       *paths;

    paths = [self validScriptSearchPaths];

    pEnumerator = [paths objectEnumerator];

    while( (path = [pEnumerator nextObject]) )
    {
        // NSLog(@"IN %@", path);
        sEnumerator = [[manager directoryContentsAtPath:path] objectEnumerator];
        
        while( (file = [sEnumerator nextObject]) )
        {

            if( ! [[file pathExtension] isEqualToString:@"stinfo"] )
            {
                NSDebugLLog(@"STScriptManager", @"Script %@", file);

                str = [file lastPathComponent];
                str = [str stringByDeletingPathExtension];

                if([str isEqualToString:aString])
                {
                    return [STFileScript scriptWithFile:
                                   [path stringByAppendingPathComponent:file]];
                }
            }
        }

    }
    
    return nil;
}

- (NSArray *)_scriptsAtPath:(NSString *)path
{
    NSMutableArray *scripts = [NSMutableArray array];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator  *enumerator;
    NSString      *file;
    NSString      *ext;
    NSSet         *types;
    
    types = [NSSet setWithArray:[STLanguage allKnownFileTypes]];

    enumerator = [[manager directoryContentsAtPath:path] objectEnumerator];

    while( (file = [enumerator nextObject]) )
    {

        ext = [file pathExtension];
        if( [types containsObject:ext] )
        {
            STFileScript *script;
            NSLog(@"Found script %@", file);

            script = [STFileScript scriptWithFile: 
                        [path stringByAppendingPathComponent:file]];
            [scripts addObject:script];
        }
    }

    return [NSArray arrayWithArray:scripts];
}

/** Return list of all scripts for managed domain. */
- (NSArray *)allScripts
{
    NSMutableArray *scripts = [NSMutableArray array];
    NSEnumerator   *enumerator;
    NSString       *path;

    enumerator = [[self validScriptSearchPaths] objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
        [scripts addObjectsFromArray:[self _scriptsAtPath:path]];
    }
    
    return [NSArray arrayWithArray:scripts];
}
@end
