" NSURL  example "
[|

main
    | string result |

    ((Args count) < 1 ) 
    ifTrue: 
    [
            Transcript showLine:'Please specify an URL to download.'
    ]
    ifFalse:
    [
        Args do: 
        [ 
            :str | self download:str
        ]
    ].

    ^self
!

download:str

    | url |
    
    url := NSURL URLWithString:str.
    
    Transcript showLine:('Downloading ', (url description)).
    url loadResourceDataNotifyingClient:self
                             usingCache:YES.
                             
    NSRunLoop currentRunLoop run.
    ^self
!

URLHandleResourceDidBeginLoading:sender
    Transcript showLine:'begin'.
    ^self    
!

URLHandle:handle resourceDataDidBecomeAvailable:data
    Transcript showLine:('available ', (data length stringValue)).
    ^self
!
URLHandleResourceDidFinishLoading:sender
    Transcript showLine:'done'.
    ^self
]
