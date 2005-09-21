"a := [:x :y|[:z | x + y + z] valueWith:3].

Transcript showLine:(a valueWith:5 with:7).
"
a := [:x :y|[:z | x + y + z]] valueWith:3 with:5.

Transcript showLine:(a valueWith:7).
"
    Error (NSInvalidArgumentException): GSMutableDictionary(instance) 
does not recognize isValid
    StepTalk > ([:x :y|[:z | x + y + z]] valueWith
    "