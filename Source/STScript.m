/**
    STScript
  
    Copyright (c) 2002 Stefan Urbanek
  
    Written by: Stefan Urbanek <stefanurbanek@yahoo.fr>
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

#import <StepTalk/STScript.h>

#import <StepTalk/STLanguage.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSUserDefaults.h>

@interface NSDictionary(LocalizedKey)
- (id)localizedObjectForKey:(NSString *)key;
@end

@implementation NSDictionary(LocalizedKey)
- (id)localizedObjectForKey:(NSString *)key
{
    NSEnumerator   *enumerator;
    NSDictionary   *dict;;
    NSString       *language;
    NSArray        *languages;
    id              obj = nil;
    
    languages = [NSUserDefaults userLanguages];

    enumerator = [languages objectEnumerator];

    while( (language = [enumerator nextObject]) )
    {
        dict = [self objectForKey:language];
        obj = [dict objectForKey:key];

        if(obj)
        {
            return obj;
        }
    }

    return [[self objectForKey:@"Default"] objectForKey:key];
}
@end

@implementation STScript
+ scriptWithFile:(NSString *)file
{
    STScript *script;
    
    script = [[STScript alloc] initWithFile:file];

    return AUTORELEASE(script);
}
/**
    Create a new script from file <var>aFile></var>. Script information will
    be read from 'aFile.stinfo' file containing a dictionary property list.
*/

- initWithFile:(NSString *)aFile
{
    NSFileManager  *manager = [NSFileManager defaultManager];
    NSDictionary   *info = nil;
    NSString       *infoFile;
    BOOL            isDir;

    // infoFile = [aFile stringByDeletingPathExtension];
    infoFile = [aFile stringByAppendingPathExtension: @"stinfo"];

    if([manager fileExistsAtPath:infoFile isDirectory:&isDir] && !isDir )
    {
        info = [NSDictionary dictionaryWithContentsOfFile:infoFile];
    }

    self = [super init];
    
    fileName = RETAIN(aFile);
    
    localizedName = [info localizedObjectForKey:@"Name"];

    if(!localizedName)
    {
        localizedName = [[fileName lastPathComponent] 
                                        stringByDeletingPathExtension];
    }
    
    RETAIN(localizedName);

    menuKey = RETAIN([info localizedObjectForKey:@"MenuKey"]);
    description = RETAIN([info localizedObjectForKey:@"Description"]);
    language = [info localizedObjectForKey:@"Language"];

    if(!language)
    {
        language = [STLanguage languageNameForFileType:[fileName pathExtension]];
    }
    if(!language)
    {
        language = @"Unknown";
    }
    
    RETAIN(language);
    
    return self;
}

- (void)dealloc
{
    RELEASE(fileName);
    RELEASE(localizedName);
    RELEASE(menuKey);
    RELEASE(description);
    RELEASE(language);
    [super dealloc];
}

/** Return file name of the receiver. */
- (NSString *)fileName
{
    return fileName;
}

/** Return menu item key equivalent for receiver. */
- (NSString *)menuKey
{
    return menuKey;
}

/** Returns source string of the receiver script.*/
- (NSString *)source
{
    return [NSString stringWithContentsOfFile:fileName];
}

/** Returns a script name by which the script is identified */
- (NSString *)scriptName
{
    return fileName;
}

/** Returns localized name of the receiver script. */
- (NSString *)localizedName
{
    return localizedName;
}

/** Returns localized description of the script. */
- (NSString *)scriptDescription
{
    return description;
}
/** Returns language of the script. */
- (NSString *)language
{
    return language;
}

/** Compare scripts by localized name. */
- (NSComparisonResult)compareByLocalizedName:(STScript *)aScript
{
    return [localizedName caseInsensitiveCompare:[aScript localizedName]];
}
@end
