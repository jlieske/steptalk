#import "STEnvironmentServer.h"

#import <Foundation/NSTask.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>


static STEnvironmentServer *sharedEnvironmentServer = nil;

@implementation STEnvironmentServer
+ sharedServer
{
    if(!sharedEnvironmentServer)
    {
        sharedEnvironmentServer = [[self alloc] init];
    }
    return sharedEnvironmentServer;
}
- (void)createEnvironmentWithName:(NSString *)envName
{
    NSTask   *task;
    NSString *path;
    NSArray  *args;
    NSString *pid;
    
    /* FIXME: use absolute path */
    path = @"stenvironment";
    
    pid = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
    args = [NSArray arrayWithObjects:@"-name",
                                     envName,
                                     @"-observer",
                                     pid,
                                     nil];
             
    task = [NSTask launchedTaskWithLaunchPath:path arguments:args];
    /* FIXME: remove this sleep */       
    sleep(1);
}
@end
