#import <Foundation/NSFileManager.h>
@interface NSFileManager(StepTalkAdditions)
- (NSArray *)pathsForDirectories:(NSArray *)array inDomains:(int)domains;
- (NSArray *)filesOfType:(NSString *)type inPaths:(NSArray *)paths;
@end
