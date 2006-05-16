//
//  STResourceManager.h
//  StepTalk
//
//  Created by Stefan Urbanek on 12.5.2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface STResourceManager : NSObject {
    NSArray *searchPaths;
    BOOL     searchesInLoadedBundles;
    BOOL     searchesBundlesFirst;
}
- (void)setSearchPaths:(NSArray *)array;
- (NSArray *)searchPaths;
- (void)setSearchesInLoadedBundles:(BOOL)flag;
- (BOOL)searchesInLoadedBundles;
- (void)setSearchesBundlesFirst:(BOOL)flag;
- (BOOL)searchesBundlesFirst;

- (NSArray *)findAllResourcesInDirectory:(NSString *)resourceDir
                                    type:(NSString *)type;
- (NSString *)pathForResource:(NSString *)name
                         type:(NSString *)type
                    directory:(NSString *)directory;
@end
