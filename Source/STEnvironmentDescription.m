/**
    STEnvironmentDescription.m
    Compiled scripting environment description
 
    Copyright (c) 2002 Free Software Foundation
 
    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2000 Jun 16
 
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

#import <StepTalk/STEnvironmentDescription.h>

#import <StepTalk/STClassInfo.h>
#import <StepTalk/STExterns.h>
#import <StepTalk/STFunctions.h>
#import <StepTalk/STBehaviourInfo.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSUserDefaults.h>

static NSDictionary *dictForDescriptionWithName(NSString *defName)
{
    NSString     *file;
    NSDictionary *dict;

    file = STFindResource(defName,
                          STScriptingEnvironmentsDirectory,
                          STScriptingEnvironmentExtension);

    if(!file)
    {
        [NSException raise:STGenericException
                    format: @"Could not find "
                            @"environment description with name '%@'.",
                            defName];
        return nil;
    }

    dict = [NSDictionary dictionaryWithContentsOfFile:file];

    if(!dict)
    {
        [NSException raise:STGenericException
                    format:@"Error while opening "
                           @"environment description with name '%@'.",
                           defName];

        return nil;
    }

    return dict;
}

@interface STEnvironmentDescription(PrivateMethods)
- (void)updateFromDictionary:(NSDictionary *)def;
- (void)updateUseListFromDictionary:(NSDictionary *)def;
- (void)updateBehavioursFromDictionary:(NSDictionary *)aDict;
- (void)updateBehaviour:(STBehaviourInfo *)behInfo
            description:(NSDictionary *)def;
- (void)updateClassesFromDictionary:(NSDictionary *)def;
- (void)updateClassWithName:(NSString *)className description:(NSDictionary *)def;
- (void)updateAliasesFromDictionary:(NSDictionary *)def;
- (void)fixupScriptingDescription;
- (void)resolveSuperclasses;
@end

@implementation STEnvironmentDescription
+ (NSString *)defaultEnvironmentDescriptionName
{
    NSUserDefaults *defs;
    NSDictionary   *dict;
    NSString       *name;
    
    defs = [NSUserDefaults standardUserDefaults];
    name = [defs objectForKey:@"STDefaultEnvironmentDescriptionName"];
    
    if(!name || [name isEqualToString:@""])
    {
        name = [NSString stringWithString:@"Standard"];
    }
    
    return name;
}

+ descriptionWithName:(NSString *)descriptionName
{
    return AUTORELEASE([[self alloc] initWithName:descriptionName]);
}
+ descriptionFromDictionary:(NSDictionary *)dictionary
{
    return AUTORELEASE([[self alloc] initFromDictionary:dictionary]);
}
- (void)dealloc
{
    RELEASE(usedDefs);
    RELEASE(classes);
    RELEASE(behaviours);
    RELEASE(aliases);
    RELEASE(modules);
    RELEASE(finders);
    
    [super dealloc];
}

- initWithName:(NSString *)defName;
{
    return [self initFromDictionary:dictForDescriptionWithName(defName)];
}

- initFromDictionary:(NSDictionary *)def
{
    if(!def)
    {
        [self dealloc];
        return nil;
    }    
    
    [self updateFromDictionary:def];
    [self fixupScriptingDescription];
    
    return self;
}

- (void)updateFromDictionary:(NSDictionary *)def
{
    NSString *str;
    BOOL      saveFlag = restriction;
    
    if(!def)
    {
        NSLog(@"Warning: nil dictionary for environmet description update");
        return;
    };
    
    str = [def objectForKey:@"DefaultRestriction"];
    
    if(str)
    {
        str = [str lowercaseString];

        if([str isEqualToString:@"allowall"])
        {
            restriction = STAllowAllRestriction;
        }
        else if([str isEqualToString:@"denyall"])
        {
            restriction = STDenyAllRestriction;
        }
        else
        {
            [NSException raise:STGenericException
                        format:@"Invalid default restriction rule '%@'.",
                                str];
            return;                               
        }
    }

    [self updateUseList:[def objectForKey:@"Use"]];
    [self updateModuleList:[def objectForKey:@"Modules"]];
    [self updateFinderList:[def objectForKey:@"Finders"]];
    [self updateBehavioursFromDictionary:[def objectForKey:@"Behaviours"]];
    [self updateClassesFromDictionary:[def objectForKey:@"Classes"]];
    [self updateAliasesFromDictionary:[def objectForKey:@"Aliases"]];

    restriction = saveFlag;
}

- (void)updateUseList:(NSArray *)array
{
    NSEnumerator *enumerator;
    NSString     *str;

    enumerator = [array objectEnumerator];

    while( (str = [enumerator nextObject]) )
    {
        if(!usedDefs)
        {
            usedDefs = [[NSMutableArray alloc] init];
        } 
    
        if( ![usedDefs containsObject:str] )
        {
            [usedDefs addObject:str];
            [self updateFromDictionary:dictForDescriptionWithName(str)];
        }
        
    }
}

- (void)updateModuleList:(NSArray *)array
{
    NSEnumerator *enumerator;
    NSString     *str;

    enumerator = [array objectEnumerator];

    while( (str = [enumerator nextObject]) )
    {
        if(!modules)
        {
            modules = [[NSMutableArray alloc] init];
        } 

        if( ![modules containsObject:str] )
        {
            [modules addObject:str];
        }
    }
}

- (void)updateFinderList:(NSArray *)array
{
    NSEnumerator *enumerator;
    NSString     *str;

    enumerator = [array objectEnumerator];

    while( (str = [enumerator nextObject]) )
    {
        if(!finders)
        {
            finders = [[NSMutableArray alloc] init];
        } 

        if( ![finders containsObject:str] )
        {
            [finders addObject:str];
        }
    }
}

- (void)updateBehavioursFromDictionary:(NSDictionary *)dict
{
    NSEnumerator    *enumerator;
    NSString        *name;
    
    STBehaviourInfo *behInfo;

    enumerator = [dict keyEnumerator];

    while( (name = [enumerator nextObject]) )
    {
        if([behaviours objectForKey:name])
        {
            [NSException raise:STGenericException
                        format:@"Behaviour '%@' defined more than once.",
                               name];
            return;
        }

        if(!behaviours)
        {
            behaviours = [[NSMutableDictionary alloc] init];
        }

        behInfo = [[STBehaviourInfo alloc] initWithName:name];
        [behaviours setObject:behInfo forKey:name];

        [self updateBehaviour:behInfo description:[dict objectForKey:name]];
    }

}

- (void)updateBehaviour:(STBehaviourInfo *)behInfo
            description:(NSDictionary *)def
{
    NSString     *str;
    NSEnumerator *enumerator;
    STBehaviourInfo *useInfo;
    

    enumerator = [[def objectForKey:@"Use"] objectEnumerator];
    while( (str = [enumerator nextObject]) )
    {
        useInfo = [behaviours objectForKey:str];
        if(!useInfo)
        {
            [NSException raise:STGenericException
                        format:@"Undefined behaviour '%@'.",
                                str];
            return;
        }

        [behInfo adopt:useInfo];
    }
    
    [behInfo allowMethods:[NSSet setWithArray:[def objectForKey:@"AllowMethods"]]];
    [behInfo denyMethods:[NSSet setWithArray:[def objectForKey:@"DenyMethods"]]];

    [behInfo addTranslationsFromDictionary:[def objectForKey:@"SymbolicSelectors"]];

    [behInfo addTranslationsFromDictionary:[def objectForKey:@"Aliases"]];
}

- (void)updateClassesFromDictionary:(NSDictionary *)dict
{
    NSEnumerator *enumerator;
    NSString     *str;

    enumerator = [dict keyEnumerator];

    while( (str = [enumerator nextObject]) )
    {
        [self updateClassWithName:str 
                      description:[dict objectForKey:str]];
    }
    
}

- (void)updateClassWithName:(NSString *)className description:(NSDictionary *)def
{
    STClassInfo *class;
    NSString    *superName;
    NSString    *flag;
    NSString    *str;
    
    BOOL         newClass = NO;

    if(!classes)
    {
        classes = [[NSMutableDictionary alloc] init];
    }

    class = [classes objectForKey:className];

    if( !class )
    {
        class = [[STClassInfo alloc] initWithName:className];
        [classes setObject:class forKey:className];
        newClass = YES;
    }

    str = [def objectForKey:@"Super"];
    superName = [class superclassName];
    
    if(str && (![str isEqualToString:superName]))
    {
        if(newClass | (superName == nil))
        {
            [class setSuperclassName:str];
        }
        else
        {
            [NSException raise:STGenericException
                         format:@"Trying to change superclass of '%@' "
                                @"from '%@' to '%@'",
                                className,[class superclassName],str];
            return;
        }
    }
    
    [self updateBehaviour:class description:def];

    flag = [def objectForKey:@"Restriction"];

    NSDebugLLog(@"STEnvironment", @"Class %@ restriction %@ (default %i)", 
               className, flag, restriction);
    
    if(flag)
    {
        flag = [flag lowercaseString];

        if([flag isEqualToString:@"allowall"])
        {
            [class setAllowAllMethods:YES];
        }
        else if([flag isEqualToString:@"denyall"])
        {
            [class setAllowAllMethods:NO];
        }
        else
        {
            [NSException raise:STGenericException
                        format:@"Invalid method restriction rule '%@'.",
                                flag];
            return;                               
        }
    }
    else
    {
        if(restriction == STAllowAllRestriction)
        {
            [class setAllowAllMethods:YES];
        }
        else if (restriction == STDenyAllRestriction)
        {
            [class setAllowAllMethods:NO];
        }
    }
}

- (void)updateAliasesFromDictionary:(NSDictionary *)dict
{
    NSEnumerator *enumerator;
    NSString     *str;

    enumerator = [dict keyEnumerator];

    while( (str = [enumerator nextObject]) )
    {
        [aliases setObject:str forKey:[dict objectForKey:str]];
    }
}

- (NSMutableDictionary *)classes
{
    return classes;
}

- (NSArray *)modules
{
    return [NSArray arrayWithArray:modules];
}

- (NSArray *)objectFinders
{
    return [NSArray arrayWithArray:finders];
}


- (void)fixupScriptingDescription
{
    [self resolveSuperclasses];
}

- (void)resolveSuperclasses
{
    NSEnumerator *enumerator;
    STClassInfo  *superclass;
    STClassInfo  *class;
    NSString     *className;
    
    enumerator = [classes objectEnumerator];
                
    while( (class = [enumerator nextObject]) )
    {
        if([[class behaviourName] isEqualToString:@"All"])
        {
            continue;
        }
        
        className = [class superclassName];
        
        if( (className == nil) || [className isEqualToString:@"nil"] )
        {
            superclass = [classes objectForKey:@"All"];

            if(!superclass)
            {
                continue;
            }
        }
        else
        {
            superclass = [classes objectForKey:className];
        }

        if(!superclass)
        {
            [NSException raise:STGenericException
                         format:@"Resolving superclasses: "
                                @"Could not find class '%@'.", className];
            return;
        }
        
        [class setSuperclassInfo:superclass];
    }
}
@end
