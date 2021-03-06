SystemOrganization addCategory: #'Coroutines-CAP-2017'!

Object subclass: #Coroutine
	instanceVariableNames: 'block cont'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Coroutines-CAP-2017'!

!Coroutine commentStamp: '<historical>' prior: 0!
A Coroutine is coroutine.
!

!Coroutine class methodsFor: 'instance creation' stamp: 'AlbertLobo 12/27/2016 10:41'!
maker: aBlock
	"create an instance"
	^ self new initializeOn: aBlock.
	! !

!Coroutine methodsFor: 'initailize-release' stamp: 'AlbertLobo 12/27/2016 10:43'!
initializeOn: aBlock
	"aBlock is the coroutine"
	block := aBlock.! !

!Coroutine methodsFor: 'clearing' stamp: 'AlbertLobo 1/18/2017 00:54'!
reset
	"reset the coroutine so next time it starts at the begining of the block"
	cont := nil.! !

!Coroutine methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 00:53'!
value: aValue
	"execute coroutine"
	^ (cont isNil)
		ifTrue: [ block 
			value: [ :coroutine :value | 
				cont := thisContext sender.
				coroutine value: value.
			]
			value: aValue
		]
		ifFalse: [ 
			| contTmp |
			contTmp := cont.
			cont := nil.
			thisContext swapSender:  contTmp.
			aValue.
		]! !

Object subclass: #CoroutineCont
	instanceVariableNames: 'block cont'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Coroutines-CAP-2017'!

!CoroutineCont commentStamp: '<historical>' prior: 0!
A CoroutineCont is a coroutine.

Instance Variables
	block:		<Object>
	cont:		<Object>
	first:		<Object>

block
	- block that contains the coroutine code

cont
	- continuation where the coroutine stopped execution
!

!CoroutineCont class methodsFor: 'instance creation' stamp: 'AlbertLobo 1/18/2017 14:42'!
maker: aBlock
	"comment stating purpose of message"
	^ CoroutineCont new initializeWith: aBlock.! !

!CoroutineCont methodsFor: 'initialize-release' stamp: 'AlbertLobo 1/18/2017 14:47'!
initializeWith: aBlock 
	"initialize with a block that contains the coroutine code"
	block := aBlock.
	cont := nil.! !

!CoroutineCont methodsFor: 'clearing' stamp: 'AlbertLobo 1/18/2017 15:03'!
reset
	"reset the coroutine so next time it starts at the begining of the block"
	cont := nil.! !

!CoroutineCont methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 20:57'!
value: aValue
	"comment stating purpose of message"
	^ (cont isNil) 
		ifTrue: [ 
			block 
				value: [ :coroutine :value | 
					Continuation callcc: [ :executionFlow |
						cont := executionFlow.
						coroutine value: value.
					]
				]
				value: aValue.
		]
		ifFalse: [ 
			| contTmp |
			contTmp := cont.
			cont := nil.
			contTmp value: aValue.
		]! !

Object subclass: #StableMarriage
	instanceVariableNames: 'n guys gals guyPrefs galPrefs solver guyCors galCors guyEng galEng galPrefsOrd trace'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Coroutines-CAP-2017'!

!StableMarriage commentStamp: '<historical>' prior: 0!
A StableMarriage solves the 'stable marriage' problem using coroutines.
!

!StableMarriage class methodsFor: 'action' stamp: 'AlbertLobo 1/18/2017 15:21'!
solve: aValue
	"comment stating purpose of message"! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:39'!
galPrefs
	^ galPrefs! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:40'!
galPrefs: anArray
	galPrefs := anArray! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:39'!
gals
	^ gals! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:40'!
gals: anArray
	gals := anArray! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:39'!
guyPrefs
	^ guyPrefs! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:39'!
guyPrefs: anArray
	guyPrefs := anArray! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:39'!
guys
	^ guys! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:52'!
guys: anArray
	guys := anArray! !

!StableMarriage methodsFor: 'helper methods' stamp: 'AlbertLobo 1/18/2017 16:44'!
prepareCoroutines
	"prepare coroutines to solve the problem"
	"shut up, pharo prompt!!"
	guyCors := galCors := solver := nil.
	
	"guy's coroutines"
	guyCors := (1 to: n) collect: [ :i |
		| guy |
		guy := i.
		Coroutine maker: [ :resume :value |
			| prefs gal |
			prefs := guyPrefs at: guy.
			(1 to: n) do: [ :j |
				"make guy-girl engagement"
				gal := prefs at: j.
				guyEng at: guy put: gal.
				trace ifTrue: [ self traceOn: { (guys at: guy). 'proposes'. (gals at: gal) } ].
				resume value: (galCors at: gal) value: guy.
			].
		].
	].
	
	"gal coroutines"
	galCors := (1 to: n) collect: [ :i |
		| gal |
		gal := i.
		Coroutine maker: [ :resume :value |
			| prefs guy |
			prefs := galPrefsOrd at: gal.
			guy := value.
			galEng at: gal put: guy.
			trace ifTrue: [ self traceOn: { (gals at: gal). 'accepts initial'. (guys at: guy) } ].
			"first guy accepted: back to main"
			guy := resume value: solver value: nil. 
			[ true ] whileTrue: [ 
				( (prefs at: (galEng at: gal)) > (prefs at: guy) )
					ifTrue: [ 
						| jilt |
						jilt := galEng at: gal. 
						galEng at: gal put: guy.
						trace ifTrue: [ self traceOn: { (gals at: gal). 'prefers'. (guys at: guy). 'over'. (guys at: jilt) } ].
						"new guy accepted: back to jilt"
						guy := resume value: (guyCors at: jilt) value: gal. 
					]
					ifFalse: [ 
						trace ifTrue: [ self traceOn: { (gals at: gal). 'rejects'. (guys at: guy) } ].	
						"guy rejected: back to guy"	
						guy := resume value: (guyCors at: guy) value: gal.
					]
			].
		].
	].
	
	"solver coroutine"
	solver := Coroutine maker: [ :resume :value |
		(1 to: n) do: [ :guy |
			resume value: (guyCors at: guy) value: nil.
		].
		trace ifTrue: [ self traceResults ].
		guyEng.
	].

	
	! !

!StableMarriage methodsFor: 'helper methods' stamp: 'AlbertLobo 1/18/2017 16:15'!
prepareParameters
	"prepare paramters to solve the problem"
	n := guys size.
	
	"engagements for guys and girls"
	guyEng := Array new: n.
	galEng := Array new: n.
	
	"girls preferences by guy index"
	galPrefsOrd := (1 to: n) collect: [ :i |
		| prefs prefsOrd |
		prefs := galPrefs at: i.
		prefsOrd := Array new: n.
		(1 to: n) do: [ :j | 
			prefsOrd at: (prefs at: j) put: j.
		].
		prefsOrd.
	].
	! !

!StableMarriage methodsFor: 'action' stamp: 'AlbertLobo 1/18/2017 16:26'!
solve
	"solves the problem. It is assumed all parameters are set correctly"
	self prepareParameters.
	self prepareCoroutines.
	^ solver value: nil.
	! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:52'!
trace
	^ trace! !

!StableMarriage methodsFor: 'accessing' stamp: 'AlbertLobo 1/18/2017 15:51'!
trace: aBool
	trace := aBool! !

!StableMarriage methodsFor: 'helper methods' stamp: 'AlbertLobo 1/18/2017 16:49'!
traceOn: anArray
	"show all the element s of anArray on a line"
	Transcript show: (anArray joinUsing: ' '); cr.! !

!StableMarriage methodsFor: 'helper methods' stamp: 'AlbertLobo 1/18/2017 16:50'!
traceResults
	"print in Transcript the resulting engagements"
	Transcript cr; show: 'Final engagements:'; cr.
	(1 to: n) do: [ :i |
		self traceOn: { (guys at: i). 'marries'. (gals at: (guyEng at: i)) }.
	].! !

TestCase subclass: #CoroutineContTest
	instanceVariableNames: 'statementTestResult theForceTestResult alphabetTestResult sumOneToNTestResult1 sumOneToNTestResult2 sumOneToNTestResult3 resetTestResult'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Coroutines-CAP-2017'!

!CoroutineContTest methodsFor: 'initialization' stamp: 'AlbertLobo 1/18/2017 14:51'!
setUp
	"setup method"
	statementTestResult := 
'This is A
       This is B
           This is C
Came from C
Back in A
           Came from A
           Back in C
       Came from C
       Back in B
Came from B'.
	
	theForceTestResult := 
'fear leads to anger
anger leads to hate
hate leads to suffering
'.
	
	alphabetTestResult := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
	
	sumOneToNTestResult1 := 55.
	sumOneToNTestResult2 := 10.
	sumOneToNTestResult3 := 6.

	resetTestResult :=
'Hi
Hola
Hola
Bye'.! !

!CoroutineContTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 14:53'!
testAlphabet
	"create an alphabet using coroutines"
	| main gen res |
	main:= gen := nil.
	main := CoroutineCont maker: [  :resume :value |
		| str |
		str := ''.
		(1 to: value) do: [ :i |
			str := str, (resume value: gen value: nil) asString.
		].
		str.
	].
	gen := CoroutineCont maker: [  :resume :value |
		| index |
		index := 10.
		[ index <= 35 ] whileTrue: [ 
			resume value: main value: (Character digitValue: index).
			index := index + 1.
		].
	].
	res := main value: 26.
	self assert: alphabetTestResult = res.! !

!CoroutineContTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 15:04'!
testReset
	"test the reset function"
	| res a b |
	a := b := nil.
	res := OrderedCollection new.
	a := CoroutineCont maker: [ :resume :value |
		res add: 'Hi'.
		res add: (resume value: b value: nil).
		b reset.
		res add: (resume value: b value: nil).
		res add: 'Bye'.
	].
	b := CoroutineCont maker: [ :resume :value |
		res add: (resume value: a value: 'Hola').
		res add: 'Adeu'.
	].
	a value: nil.
	res := res joinUsing: Character cr asString.
	self assert: resetTestResult = res.! !

!CoroutineContTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 14:55'!
testStatement
	"test given with the problem statement"
	| res a b c |
	a := b := c := 0.
	res := OrderedCollection new.
	a := CoroutineCont maker: [ :resume :value |
		res add: 'This is A'.
		res add: ('Came from ', (resume value: b value: 'A')). 
		res add: 'Back in A'.
		res add: ('Came from ', (resume value: c value: 'A')).  
	].
	b := CoroutineCont maker: [ :resume :value |
		res add: '       This is B'.
		res add: ('       Came from ', (resume value: c value: 'B')). 
		res add: '       Back in B'.
		res add: ('       Came from ', (resume value: a value: 'B')).  
	].
	c := CoroutineCont maker: [ :resume :value |
		res add: '           This is C'.
		res add: ('           Came from ', (resume value: a value:'C')). 
		res add: '           Back in C'.
		res add: ('           Came from ', (resume value: b value: 'C')).
	].
	a value: nil.	
	res := res joinUsing: Character cr asString.
	self assert: statementTestResult = res.! !

!CoroutineContTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 14:56'!
testSumOneToN
	"use coroutines to get  the summation on 1 to n"
	| sum res1 res2 res3 |
	sum := nil.
	sum := CoroutineCont maker: [ :resume :value |
		| x |
		x := 0.
		[ value > 0 ] whileTrue: [ 
			x := x + value.
			value := resume value: sum value: (value - 1).
		].
		x.
	].
	res1 := sum value: 10.
	res2 := sum value: 4.
	res3 := sum value: 3.
	self assert: res1 == sumOneToNTestResult1.
	self assert: res2 == sumOneToNTestResult2.
	self assert: res3 == sumOneToNTestResult3.! !

!CoroutineContTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 14:56'!
testTheForce
	"join an array of words to get Yoda's famous quote"
	| res a b c words |
	a := b := c := nil.
	res := OrderedCollection new.
	words := OrderedCollection withAll: #('fear' 'anger' 'hate' 'suffering').
	a := CoroutineCont maker: [ :resume :value |
		[ (words size) > 1 ] whileTrue: [ 
			res add: (resume value: c value: (words first)); add: Character cr asString.
		].
	].
	b := CoroutineCont maker: [ :resume :value |
		[ true ] whileTrue: [ 
			res add: (resume value: a value: (words first)).
		].
	].
	c := CoroutineCont maker: [ :resume :value |
		res add: value; add: ' leads to '.
		[ true ] whileTrue: [ 
			words removeFirst.
			res add: (resume value: b value: ' leads to ').
		].
	].
	a value: nil.
	res := res joinUsing: ''.
	self assert: theForceTestResult = res.! !

TestCase subclass: #CoroutineTest
	instanceVariableNames: 'statementTestResult theForceTestResult alphabetTestResult sumOneToNTestResult1 sumOneToNTestResult2 sumOneToNTestResult3 resetTestResult'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Coroutines-CAP-2017'!

!CoroutineTest methodsFor: 'initialization' stamp: 'AlbertLobo 1/18/2017 02:24'!
setUp
	"setup method"
	statementTestResult := 
'This is A
       This is B
           This is C
Came from C
Back in A
           Came from A
           Back in C
       Came from C
       Back in B
Came from B'.
	
	theForceTestResult := 
'fear leads to anger
anger leads to hate
hate leads to suffering
'.
	
	alphabetTestResult := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
	
	sumOneToNTestResult1 := 55.
	sumOneToNTestResult2 := 10.
	sumOneToNTestResult3 := 6.

	resetTestResult :=
'Hi
Hola
Hola
Bye'.! !

!CoroutineTest methodsFor: 'test' stamp: 'AlbertLobo 1/17/2017 23:57'!
testAlphabet
	"create an alphabet using coroutines"
	| main gen res |
	main:= gen := nil.
	main := Coroutine maker: [  :resume :value |
		| str |
		str := ''.
		(1 to: value) do: [ :i |
			str := str, (resume value: gen value: nil) asString.
		].
		str.
	].
	gen := Coroutine maker: [  :resume :value |
		| index |
		index := 10.
		[ index <= 35 ] whileTrue: [ 
			resume value: main value: (Character digitValue: index).
			index := index + 1.
		].
	].
	res := main value: 26.
	self assert: alphabetTestResult = res.! !

!CoroutineTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 02:24'!
testReset
	"test the reset function"
	| res a b |
	a := b := nil.
	res := OrderedCollection new.
	a := Coroutine maker: [ :resume :value |
		res add: 'Hi'.
		res add: (resume value: b value: nil).
		b reset.
		res add: (resume value: b value: nil).
		res add: 'Bye'.
	].
	b := Coroutine maker: [ :resume :value |
		res add: (resume value: a value: 'Hola').
		res add: 'Adeu'.
	].
	a value: nil.
	res := res joinUsing: Character cr asString.
	self assert: resetTestResult = res.! !

!CoroutineTest methodsFor: 'test' stamp: 'AlbertLobo 1/17/2017 23:58'!
testStatement
	"test given with the problem statement"
	| res a b c |
	a := b := c := 0.
	res := OrderedCollection new.
	a := Coroutine maker: [ :resume :value |
		res add: 'This is A'.
		res add: ('Came from ', (resume value: b value: 'A')). 
		res add: 'Back in A'.
		res add: ('Came from ', (resume value: c value: 'A')).  
	].
	b := Coroutine maker: [ :resume :value |
		res add: '       This is B'.
		res add: ('       Came from ', (resume value: c value: 'B')). 
		res add: '       Back in B'.
		res add: ('       Came from ', (resume value: a value: 'B')).  
	].
	c := Coroutine maker: [ :resume :value |
		res add: '           This is C'.
		res add: ('           Came from ', (resume value: a value:'C')). 
		res add: '           Back in C'.
		res add: ('           Came from ', (resume value: b value: 'C')).
	].
	a value: nil.	
	res := res joinUsing: Character cr asString.
	self assert: statementTestResult = res.! !

!CoroutineTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 00:50'!
testSumOneToN
	"use coroutines to get  the summation on 1 to n"
	| sum res1 res2 res3 |
	sum := nil.
	sum := Coroutine maker: [ :resume :value |
		| x |
		x := 0.
		[ value > 0 ] whileTrue: [ 
			x := x + value.
			value := resume value: sum value: (value - 1).
		].
		x.
	].
	res1 := sum value: 10.
	res2 := sum value: 4.
	res3 := sum value: 3.
	self assert: res1 == sumOneToNTestResult1.
	self assert: res2 == sumOneToNTestResult2.
	self assert: res3 == sumOneToNTestResult3.! !

!CoroutineTest methodsFor: 'test' stamp: 'AlbertLobo 1/17/2017 23:56'!
testTheForce
	"join an array of words to get Yoda's famous quote"
	| res a b c words |
	a := b := c := nil.
	res := OrderedCollection new.
	words := OrderedCollection withAll: #('fear' 'anger' 'hate' 'suffering').
	a := Coroutine maker: [ :resume :value |
		[ (words size) > 1 ] whileTrue: [ 
			res add: (resume value: c value: (words first)); add: Character cr asString.
		].
	].
	b := Coroutine maker: [ :resume :value |
		[ true ] whileTrue: [ 
			res add: (resume value: a value: (words first)).
		].
	].
	c := Coroutine maker: [ :resume :value |
		res add: value; add: ' leads to '.
		[ true ] whileTrue: [ 
			words removeFirst.
			res add: (resume value: b value: ' leads to ').
		].
	].
	a value: nil.
	res := res joinUsing: ''.
	self assert: theForceTestResult = res.! !

TestCase subclass: #StableMarriageTest
	instanceVariableNames: 'peanutsTestResult statementTestResult oneTestResult'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Coroutines-CAP-2017'!

!StableMarriageTest methodsFor: 'initialization' stamp: 'AlbertLobo 1/18/2017 19:19'!
setUp
	peanutsTestResult := #( 2 3 1 4 ).
	statementTestResult := #( 3 1 2 ).
	oneTestResult := #( 1 ).! !

!StableMarriageTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 19:23'!
testOne
	"només una parella"
	| solver res guys gals guyPrefs galPrefs |
	"names"
	guys := #( 'Albert' ).
	gals := #( 'Ema'	).
	"preferences"
	guyPrefs := #( #( 1 ) ).
	galPrefs := #( #( 1 ) ).
	"init solver"
	solver := StableMarriage new.
	solver guys: guys.
	solver gals: gals.
	solver guyPrefs: guyPrefs.
	solver galPrefs: galPrefs.
	solver trace: true.
	res := solver solve.
	self assert: oneTestResult = res.! !

!StableMarriageTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 17:15'!
testPeanuts
	"stable marriage problem with the Peanuts characters"
	| solver res guys gals guyPrefs galPrefs |
	"names"
	guys := #(
		'Charlie'
		'Linus'
		'Schroeder'
		'Franklin'
	).
	gals := #(
		'Lucy'
		'Peppermint'
		'Marcie'
		'Sally'
	).
	"preferences"
	guyPrefs := #(
		"Charlie"
		#(
			1 "Lucy"
			2 "Peppermint"
			3 "Marcie"
			4 "Sally"
		)
		"Linus"
		#(
			3 "Marcie"
			4 "Sally"
			2 "Peppermint"
			1 "Lucy"
		)
		"Schroeder"
		#(
			3 "Marcie"
			1 "Lucy"
			2 "Peppermint"
			4 "Sally"
		)
		"Franklin"
		#(
			2 "Peppermint"
			4 "Sally"
			3 "Marcie"
			1 "Lucy"
		)
	).
	galPrefs := #(
		"Lucy"
		#(
			3 "Schroeder"
			1 "Charlie"
			4 "Franklin"
			2 "Linus"
		)
		"Peppermint"
		#(
			1 "Charlie"
			2 "Linus"
			4 "Franklin"
			3 "Schroeder"
		)
		"Marcie"
		#(
			1 "Charlie"
			4 "Franklin"
			2 "Linus"
			3 "Schroeder"
		)
		"Sally"
		#(
			2 "Linus"
			4 "Franklin"
			3 "Schroeder"
			1 "Charlie"
		)
	).
	"init solver"
	solver := StableMarriage new.
	solver guys: guys.
	solver gals: gals.
	solver guyPrefs: guyPrefs.
	solver galPrefs: galPrefs.
	solver trace: true.
	res := solver solve.
	self assert: peanutsTestResult = res.! !

!StableMarriageTest methodsFor: 'test' stamp: 'AlbertLobo 1/18/2017 17:21'!
testStatement
	"prova l'exemple del PDF 'allison-1983'"
	| solver res guys gals guyPrefs galPrefs |
	"names"
	guys := #(
		'1'
		'2'
		'3'
	).
	gals := #(
		'A'
		'B'
		'C'
	).
	"preferences"
	guyPrefs := #(
		"1"
		#(
			1 "A"
			2 "B"
			3 "C"
		)
		"2"
		#(
			1 "A"
			3 "C"
			2 "B"
		)
		"3"
		#(
			2 "B"
			3 "C"
			1 "A"
		)
	).
	galPrefs := #(
		"A"
		#(
			2 "2"
			1 "1"
			3 "3"
		)
		"B"
		#(
			2 "2"
			3 "3"
			1 "1"
		)
		"C"
		#(
			1 "1"
			2 "2"
			3 "3"
		)
	).
	"init solver"
	solver := StableMarriage new.
	solver guys: guys.
	solver gals: gals.
	solver guyPrefs: guyPrefs.
	solver galPrefs: galPrefs.
	solver trace: true.
	res := solver solve.
	self assert: statementTestResult = res.! !
