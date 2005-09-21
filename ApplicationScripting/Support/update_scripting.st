" update_scripting.st 
    
    Automatically update scripting support source files.
    
    Date: 2003 May 4
    Author: Stefan Urbanek <urbanek@host.sk>    
"

[| :root


main
    | url |

    " Source files to be updated "
    files := #('STScriptingSupport.h' 'STScriptingSupport.m').

    " Root URL of sources "
    root := NSURL URLWithString:'http://steptalk.host.sk/Download/'.

    Transcript showLine:'Downloading files from ', (root description).
    
    files do: [ :file |
        self download: file.
    ].

    Transcript showLine:'Done.'.
    
    ^self   
!

download:file
    | url data path |
    
    Transcript showLine:'  ', file.

    url := NSURL URLWithString:file relativeToURL:root.
    url := url absoluteURL.

    data := url resourceDataUsingCache:YES.
    data writeToFile:file atomically:YES.

    ^self
]
