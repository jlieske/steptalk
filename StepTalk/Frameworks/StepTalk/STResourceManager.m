//
//  STResourceManager.m
//  StepTalk
//
//  Created by Stefan Urbanek on 12.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "STResourceManager.h"

#import "STExterns.h"

static STResourceManager *defaultManager = nil;

@implementation STResourceManager
+ (STResourceManager *)defaultManager
{
    if(defaultManager == nil)
    {
        defaultManager = [[STResourceManager alloc] init];
    }
    return defaultManager;
}
+ (NSArray *)defaultSearchPaths
{
    NSFileManager *manager = [NSFileManager defaultManager];

    NSArray       *paths;
    NSEnumerator  *enumerator;
    NSString      *path;
    NSMutableArray *array;
    
    array = [NSMutableArray array];
    
    paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory,
                                                NSAllDomainsMask, YES);
    
    enumerator = [paths objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
        
        path = [path stringByAppendingPathComponent:STLibraryDirectory];

        if( [manager fileExistsAtPath:path] )
        {
            [array addObject:path];
        }
    }
    return array;
}
- init
{
    self = [super init];
    [self setSearchPaths:[STResourceManager defaultSearchPaths]];
    searchesInLoadedBundles = YES;
    return self;
}
- (void)setSearchPaths:(NSArray *)array
{
    [array retain];
    [searchPaths release];
    searchPaths = array;
}
- (NSArray *)searchPaths
{
    return searchPaths;
}
- (void)setSearchesInLoadedBundles:(BOOL)flag
{
    searchesInLoadedBundles = flag;
}
- (BOOL)searchesInLoadedBundles
{
    return searchesInLoadedBundles;
}
- (void)setSearchesBundlesFirst:(BOOL)flag
{
    searchesBundlesFirst = flag;
}
- (BOOL)searchesBundlesFirst
{
    return searchesBundlesFirst;
}
- (NSString *)_pathForAnyBundleResource:(NSString *)name
                                   type:(NSString *)type
                              directory:(NSString *)directory
{
    NSEnumerator *enumerator;
    NSBundle     *bundle;
    NSString     *path = nil;
    
    enumerator = [[NSBundle allFrameworks] objectEnumerator];
    
    while( (bundle = [enumerator nextObject]) )
    {
        path = [bundle pathForResource:name ofType:type inDirectory:directory];
        if(path)
        {
            return path;
        }
    }

    enumerator = [[NSBundle allBundles] objectEnumerator];
    
    while( (bundle = [enumerator nextObject]) )
    {
        path = [bundle pathForResource:name ofType:type inDirectory:directory];
        if(path)
        {
            return path;
        }
    }
    return nil;
}

- (NSArray *)_findAllBundleResourcesInDirectory:(NSString *)directory
                                           type:(NSString *)type
{
    NSFileManager         *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirs;
    NSMutableArray *resources = [NSMutableArray array];

    NSEnumerator *enumerator;
    NSBundle     *bundle;
    NSString     *path = nil;
    NSString     *file;
    
    enumerator = [[NSBundle allFrameworks] objectEnumerator];
    
    while( (bundle = [enumerator nextObject]) )
    {
        /* FIXME: append Contents? */
        path = [bundle bundlePath];
        path = [path stringByAppendingPathComponent:directory];
        dirs = [manager enumeratorAtPath:path];
        
        while( (file = [dirs nextObject]) )
        {
            if( [[[dirs directoryAttributes] fileType] 
                            isEqualToString:NSFileTypeDirectory]
                && [[file pathExtension] isEqualToString:type])
            {
                file = [path stringByAppendingPathComponent:file];
                [resources addObject:file];
            }
        }
    }
    
    enumerator = [[NSBundle allBundles] objectEnumerator];
    
    while( (bundle = [enumerator nextObject]) )
    {
        /* FIXME: append Contents? */
        path = [bundle bundlePath];
        path = [path stringByAppendingPathComponent:directory];
        dirs = [manager enumeratorAtPath:path];
        
        while( (file = [dirs nextObject]) )
        {
            if( [[[dirs directoryAttributes] fileType] 
                            isEqualToString:NSFileTypeDirectory]
                && [[file pathExtension] isEqualToString:type])
            {
                file = [path stringByAppendingPathComponent:file];
                [resources addObject:file];
            }
        }
    }
    
    return resources;
}

- (NSArray *)findAllResourcesInDirectory:(NSString *)directory
                                    type:(NSString *)type
{
    NSFileManager         *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirs;
    NSEnumerator  *enumerator;
    NSString      *path;
    NSString      *file;
    NSMutableArray *resources = [NSMutableArray array];
        
    enumerator = [searchPaths objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
        path = [path stringByAppendingPathComponent:STLibraryDirectory];
        path = [path stringByAppendingPathComponent:directory];
        
        if( ![manager fileExistsAtPath:path] )
        {
            continue;
        }
        
        dirs = [manager enumeratorAtPath:path];
        
        while( (file = [dirs nextObject]) )
        {
            if( [[[dirs directoryAttributes] fileType] 
                            isEqualToString:NSFileTypeDirectory]
                && [[file pathExtension] isEqualToString:type])
            {
                file = [path stringByAppendingPathComponent:file];
                [resources addObject:file];
            }
        }
    }
    
    if(searchesInLoadedBundles)
    {
        NSArray *bundleResources;
        
        bundleResources = [self _findAllBundleResourcesInDirectory:directory
                                                              type:type];
        
        if(searchesBundlesFirst)
        {
            resources = [bundleResources arrayByAddingObjectsFromArray:resources];            
        }
        else
        {
            [resources addObjectsFromArray:bundleResources];
        }

    }

    return [NSArray arrayWithArray:resources];
}

- (NSString *)pathForResource:(NSString *)name
                       ofType:(NSString *)type
                  inDirectory:(NSString *)directory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator  *enumerator;
    NSString      *path;
    NSString      *file = nil;
    
    if(searchesInLoadedBundles && searchesBundlesFirst)
    {
        file = [self _pathForAnyBundleResource:name
                                          type:type
                                     directory:directory];
        if(file)
        {
            return file;
        }
    }

    enumerator = [searchPaths objectEnumerator];

    while( (path = [enumerator nextObject]) )
    {
        
        file = [path stringByAppendingPathComponent:STLibraryDirectory];
        file = [file stringByAppendingPathComponent:directory];
        file = [file stringByAppendingPathComponent:name];
        file = [file stringByAppendingPathExtension:type];

        if( [manager fileExistsAtPath:file] )
        {
            return file;
        }
    }

    if(searchesInLoadedBundles && !searchesBundlesFirst)
    {
        file = [self _pathForAnyBundleResource:name
                                          type:type
                                     directory:directory];
        if(file)
        {
            return file;
        }
    }

    return nil;
}
@end
