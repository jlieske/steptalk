==========================
void awakeFromNib
==========================

x := 0
y := 0

==========================
void addNumber: sender
==========================

| number |
number := sender selectedCell tag.
x := (x*10) + number.
display setIntValue: x.

==========================
void equal: sender
==========================

(lastOperation = 1) ifTrue: [ x := y + x ].
(lastOperation = 2) ifTrue: [ x := y - x ].
(lastOperation = 3) ifTrue: [ x := y * x ].
(lastOperation = 4) ifTrue: [ x := y / x ].

lastOperation := 5.
display setIntValue: x.
y := x.
x := 0.

==========================
void operation: sender
==========================

(lastOperation = 5) ifTrue: [ x := y ].
lastOperation := sender selectedCell tag.
y := x.
x := 0.

==========================
void clear: sender
==========================

x := 0.
y := 0.
display setIntValue: 0.

