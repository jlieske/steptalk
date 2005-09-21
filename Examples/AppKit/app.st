" Whole application written in StepTalk/Smalltalk

    Author: Matthew D Swank
    Date: 2005 Feb 18
    
"

|object engine|

Environment loadModule:'AppKit'.
Environment includeFramework:'StepTalkLocalLib'.

"object := STScriptObject scriptObject."
object := STExtendedScriptObject alloc
    initWithInstanceVariableArray: #('window' 'label' 'menu').
object setEnvironment: Environment.

engine := STEngine engineForLanguageWithName:'Smalltalk'.

object  addMethod:
    (engine methodFromSource:
        'applicationWillFinishLaunching: notification

           window := NSWindow alloc
                              initWithContentRect:
                                  (STLLUtil makeRectX:300
                                            withY:300
                                            withW:200
                                            withH:100)
                              styleMask:15
                              backing: NSBackingStoreBuffered
                              defer: YES.
           window setTitle:\'Hello World\'.

           label := NSTextField alloc
                                initWithFrame:(STLLUtil makeRectX:30
                                                        withY:30
                                                        withW:80
                                                        withH:30).
           label setSelectable:NO.
           label setBezeled:NO.
           label setDrawsBackground:NO.
           label setStringValue:\'Hello World\'.
       
           window contentView addSubview: label.
          
           menu := NSMenu new.
           menu addItemWithTitle: \'Info\'
                          action: nil
                   keyEquivalent: \'\'.

           menu addItemWithTitle: \'Hide\'
                          action: #hide:
                   keyEquivalent: \'h\'.

           menu addItemWithTitle: \'Quit\'
                          action: #terminate:
                   keyEquivalent: \'q\'.

           info := NSMenu new.
           (info addItemWithTitle: \'Info Panel...\'
                          action: #orderFrontStandardInfoPanel:
                   keyEquivalent: \'\') setTarget: self.

           info addItemWithTitle: \'Preferences\'
                          action: nil
                   keyEquivalent: \'\'.

           info addItemWithTitle: \'Help\'
                          action: #orderFrontHelpPanel:
                   keyEquivalent: \'?\'.

           menu setSubmenu: info
                         forItem: (menu itemWithTitle:\'Info\').

           application setMainMenu:menu.'
        forReceiver: object
        inEnvironment: Environment).

object  addMethod:
    (engine methodFromSource:
        'applicationDidFinishLaunching: notification
           window makeKeyAndOrderFront: self.'
        forReceiver: object
        inEnvironment: Environment).

object  addMethod:
    (engine methodFromSource:
        'applicationShouldTerminateAfterLastWindowClosed: application
          ^true'
        forReceiver: object
        inEnvironment: Environment).

object  addMethod:
    (engine methodFromSource:
        'orderFrontStandardInfoPanel: sender
          "STLLUtil log:\'orderFrontStandardInfoPanel fired\'."
          application orderFrontStandardInfoPanelWithOptions:
                          (NSDictionary alloc
                                        initWithContentsOfFile:
                                        \'/home/singollo/Info.plist\').'
        forReceiver: object
        inEnvironment: Environment).


application := NSApplication sharedApplication.
application setDelegate: object.
application run.
