[|

main

    nc := NSWorkspace sharedWorkspace notificationCenter.
    nc addObserver:self selector:#didLaunch: 
       name:NSWorkspaceDidLaunchApplicationNotification 
       object: nil.

    NSWorkspace sharedWorkspace launchApplication:'Affiche'.

    NSRunLoop currentRunLoop runUntilDate: 
                        (NSDate dateWithTimeIntervalSinceNow:5).

    ^self
!

didLaunch:notif

    Transcript showLine: ((notif userInfo) description).

    ^self
]

