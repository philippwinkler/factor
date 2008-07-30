IN: compiler.tree.cleanup.tests
USING: tools.test kernel.private kernel arrays sequences
math.private math generic words quotations alien alien.c-types
strings sbufs sequences.private slots.private combinators
definitions system layouts vectors math.partial-dispatch
math.order math.functions accessors hashtables classes assocs
io.encodings.utf8 io.encodings.ascii io.encodings fry
compiler.tree
compiler.tree.combinators
compiler.tree.cleanup
compiler.tree.builder
compiler.tree.copy-equiv
compiler.tree.normalization
compiler.tree.propagation ;

: cleaned-up-tree ( quot -- nodes )
    build-tree normalize compute-copy-equiv propagate cleanup ;

[ t ] [ [ [ 1 ] [ 2 ] if ] cleaned-up-tree [ #if? ] contains-node? ] unit-test

[ f ] [ [ f [ 1 ] [ 2 ] if ] cleaned-up-tree [ #if? ] contains-node? ] unit-test

[ f ] [ [ { array } declare [ 1 ] [ 2 ] if ] cleaned-up-tree [ #if? ] contains-node? ] unit-test

[ t ] [ [ { sequence } declare [ 1 ] [ 2 ] if ] cleaned-up-tree [ #if? ] contains-node? ] unit-test

: recursive-test ( a -- b ) dup [ not recursive-test ] when ; inline recursive

[ t ] [ [ recursive-test ] cleaned-up-tree [ #recursive? ] contains-node? ] unit-test

[ f ] [ [ f recursive-test ] cleaned-up-tree [ #recursive? ] contains-node? ] unit-test

[ t ] [ [ t recursive-test ] cleaned-up-tree [ #recursive? ] contains-node? ] unit-test

: inlined? ( quot seq/word -- ? )
    [ cleaned-up-tree ] dip
    dup word? [ 1array ] when
    '[ dup #call? [ word>> , member? ] [ drop f ] if ]
    contains-node? not ;

[ f ] [
    [ { integer } declare >fixnum ]
    \ >fixnum inlined?
] unit-test

GENERIC: mynot ( x -- y )

M: f mynot drop t ;

M: object mynot drop f ;

GENERIC: detect-f ( x -- y )

M: f detect-f ;

[ t ] [
    [ dup [ mynot ] [ ] if detect-f ] \ detect-f inlined?
] unit-test

GENERIC: xyz ( n -- n )

M: integer xyz ;

M: object xyz ;

[ t ] [
    [ { integer } declare xyz ] \ xyz inlined?
] unit-test

[ t ] [
    [ dup fixnum? [ xyz ] [ drop "hi" ] if ]
    \ xyz inlined?
] unit-test

: (fx-repeat) ( i n quot: ( i -- i ) -- )
    2over fixnum>= [
        3drop
    ] [
        [ swap >r call 1 fixnum+fast r> ] keep (fx-repeat)
    ] if ; inline recursive

: fx-repeat ( n quot -- )
    0 -rot (fx-repeat) ; inline

! The + should be optimized into fixnum+, if it was not, then
! the type of the loop index was not inferred correctly
[ t ] [
    [ [ dup 2 + drop ] fx-repeat ] \ + inlined?
] unit-test

: (i-repeat) ( i n quot: ( i -- i ) -- )
    2over dup xyz drop >= [
        3drop
    ] [
        [ swap >r call 1+ r> ] keep (i-repeat)
    ] if ; inline recursive

: i-repeat >r { integer } declare r> 0 -rot (i-repeat) ; inline

[ t ] [
    [ [ dup xyz drop ] i-repeat ] \ xyz inlined?
] unit-test

[ t ] [
    [ { fixnum } declare dup 100 >= [ 1 + ] unless ] \ fixnum+ inlined?
] unit-test

[ t ] [
    [ { fixnum fixnum } declare dupd < [ 1 + 1 + ] when ]
    \ + inlined?
] unit-test

[ t ] [
    [ { fixnum fixnum } declare dupd < [ 1 + 1 + ] when ]
    \ + inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] times ] \ >= inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] times ] \ 1+ inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] times ] \ + inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] times ] \ fixnum+ inlined?
] unit-test

[ t ] [
    [ { integer fixnum } declare dupd < [ 1 + ] when ]
    \ + inlined?
] unit-test

[ f ] [
    [ { integer fixnum } declare dupd < [ 1 + ] when ]
    \ +-integer-fixnum inlined?
] unit-test

[ f ] [ [ dup 0 < [ neg ] when ] \ - inlined? ] unit-test

[ f ] [
    [
        [ no-cond ] 1
        [ 1array dup quotation? [ >quotation ] unless ] times
    ] \ quotation? inlined?
] unit-test

[ t ] [
    [
        1000000000000000000000000000000000 [ ] times
    ] \ + inlined?
] unit-test
[ f ] [
    [
        1000000000000000000000000000000000 [ ] times
    ] \ +-integer-fixnum inlined?
] unit-test

[ f ] [
    [ { bignum } declare [ ] times ]
    \ +-integer-fixnum inlined?
] unit-test


[ t ] [
    [ { string sbuf } declare ] \ push-all def>> append \ + inlined?
] unit-test

[ t ] [
    [ { string sbuf } declare ] \ push-all def>> append \ fixnum+ inlined?
] unit-test

[ t ] [
    [ { string sbuf } declare ] \ push-all def>> append \ >fixnum inlined?
] unit-test

[ t ] [
    [ { array-capacity } declare 0 < ] \ < inlined?
] unit-test

[ t ] [
    [ { array-capacity } declare 0 < ] \ fixnum< inlined?
] unit-test

[ t ] [
    [ { array-capacity } declare 1 fixnum- ] \ fixnum- inlined?
] unit-test

[ t ] [
    [ 5000 [ 5000 [ ] times ] times ] \ 1+ inlined?
] unit-test

[ t ] [
    [ 5000 [ [ ] times ] each ] \ 1+ inlined?
] unit-test

[ t ] [
    [ 5000 0 [ dup 2 - swap [ 2drop ] curry each ] reduce ]
    \ 1+ inlined?
] unit-test

GENERIC: annotate-entry-test-1 ( x -- )

M: fixnum annotate-entry-test-1 drop ;

: (annotate-entry-test-2) ( from to quot: ( -- ) -- )
    2over >= [
        3drop
    ] [
        [ swap >r call dup annotate-entry-test-1 1+ r> ] keep (annotate-entry-test-2)
    ] if ; inline recursive

: annotate-entry-test-2 0 -rot (annotate-entry-test-2) ; inline

[ f ] [
    [ { bignum } declare [ ] annotate-entry-test-2 ]
    \ annotate-entry-test-1 inlined?
] unit-test

[ t ] [
    [ { float } declare 10 [ 2.3 * ] times >float ]
    \ >float inlined?
] unit-test

GENERIC: detect-float ( a -- b )

M: float detect-float ;

[ t ] [
    [ { real float } declare + detect-float ]
    \ detect-float inlined?
] unit-test

[ t ] [
    [ { float real } declare + detect-float ]
    \ detect-float inlined?
] unit-test

[ t ] [
    [ 3 + = ] \ equal? inlined?
] unit-test

[ f ] [
    [ { fixnum fixnum } declare 7 bitand neg shift ]
    \ fixnum-shift-fast inlined?
] unit-test

[ t ] [
    [ { fixnum fixnum } declare 7 bitand neg shift ]
    { shift fixnum-shift } inlined?
] unit-test

[ t ] [
    [ { fixnum fixnum } declare 1 swap 7 bitand shift ]
    { shift fixnum-shift } inlined?
] unit-test

[ f ] [
    [ { fixnum fixnum } declare 1 swap 7 bitand shift ]
    { fixnum-shift-fast } inlined?
] unit-test

cell-bits 32 = [
    [ t ] [
        [ { fixnum fixnum } declare 1 swap 31 bitand shift ]
        \ shift inlined?
    ] unit-test

    [ f ] [
        [ { fixnum fixnum } declare 1 swap 31 bitand shift ]
        \ fixnum-shift inlined?
    ] unit-test
] when

[ f ] [
    [ { integer } declare -63 shift 4095 bitand ]
    \ shift inlined?
] unit-test

[ t ] [
    [ B{ 1 0 } *short 0 number= ]
    \ number= inlined?
] unit-test

[ t ] [
    [ B{ 1 0 } *short 0 { number number } declare number= ]
    \ number= inlined?
] unit-test

[ t ] [
    [ B{ 1 0 } *short 0 = ]
    \ number= inlined?
] unit-test

[ t ] [
    [ B{ 1 0 } *short dup number? [ 0 number= ] [ drop f ] if ]
    \ number= inlined?
] unit-test

[ t ] [
    [ HEX: ff bitand 0 HEX: ff between? ]
    \ >= inlined?
] unit-test

[ t ] [
    [ HEX: ff swap HEX: ff bitand >= ]
    \ >= inlined?
] unit-test

[ t ] [
    [ { vector } declare nth-unsafe ] \ nth-unsafe inlined?
] unit-test

[ t ] [
    [
        dup integer? [
            dup fixnum? [
                1 +
            ] [
                2 +
            ] if
        ] when
    ] \ + inlined?
] unit-test

[ f ] [
    [
        256 mod
    ] { mod fixnum-mod } inlined?
] unit-test

[ f ] [
    [
        dup 0 >= [ 256 mod ] when
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare dup 0 >= [ 256 mod ] when
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare 256 rem
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare [ 256 rem ] map
    ] { mod fixnum-mod rem } inlined?
] unit-test

[ t ] [
    [ 1000 [ 1+ ] map ] { 1+ fixnum+ } inlined?
] unit-test

: rec ( a -- b )
    dup 0 > [ 1 - rec ] when ; inline recursive

[ t ] [
    [ { fixnum } declare rec 1 + ]
    { > - + } inlined?
] unit-test

: fib ( m -- n )
    dup 2 < [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ; inline recursive

[ t ] [
    [ 27.0 fib ] { < - + } inlined?
] unit-test

[ f ] [
    [ 27.0 fib ] { +-integer-integer } inlined?
] unit-test

[ t ] [
    [ 27 fib ] { < - + } inlined?
] unit-test

[ t ] [
    [ 27 >bignum fib ] { < - + } inlined?
] unit-test

[ f ] [
    [ 27/2 fib ] { < - } inlined?
] unit-test

: hang-regression ( m n -- x )
    over 0 number= [
        nip
    ] [
        dup [
            drop 1 hang-regression
        ] [
            dupd hang-regression hang-regression
        ] if
    ] if ; inline recursive

[ t ] [
    [ dup fixnum? [ 3 over hang-regression ] [ 3 over hang-regression ] if
] { } inlined? ] unit-test

[ t ] [
    [ { fixnum } declare 10 [ -1 shift ] times ] \ shift inlined?
] unit-test

[ f ] [
    [ { integer } declare 10 [ -1 shift ] times ] \ shift inlined?
] unit-test

[ f ] [
    [ { fixnum } declare 1048575 fixnum-bitand 524288 fixnum- ]
    \ fixnum-bitand inlined?
] unit-test

[ t ] [
    [ { integer } declare 127 bitand 3 + ]
    { + +-integer-fixnum +-integer-fixnum-fast bitand } inlined?
] unit-test

[ f ] [
    [ { integer } declare 127 bitand 3 + ]
    { >fixnum } inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ drop ] each-integer ]
    { < <-integer-fixnum +-integer-fixnum + } inlined?
] unit-test

[ t ] [
    [ { fixnum } declare length [ drop ] each-integer ]
    { < <-integer-fixnum +-integer-fixnum + } inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ drop ] each ]
    { < <-integer-fixnum +-integer-fixnum + } inlined?
] unit-test

[ t ] [
    [ { fixnum } declare 0 [ + ] reduce ]
    { < <-integer-fixnum } inlined?
] unit-test

[ f ] [
    [ { fixnum } declare 0 [ + ] reduce ]
    \ +-integer-fixnum inlined?
] unit-test

[ t ] [
    [
        { integer } declare
        dup 0 >= [
            615949 * 797807 + 20 2^ mod dup 19 2^ -
        ] [ dup ] if
    ] { * + shift mod fixnum-mod fixnum* fixnum+ fixnum- } inlined?
] unit-test

[ t ] [
    [
        { fixnum } declare
        615949 * 797807 + 20 2^ mod dup 19 2^ -
    ] { >fixnum } inlined?
] unit-test

[ f ] [
    [
        { integer } declare [ ] map
    ] \ >fixnum inlined?
] unit-test

[ f ] [
    [
        { integer } declare { } set-nth-unsafe
    ] \ >fixnum inlined?
] unit-test

[ f ] [
    [
        { integer } declare 1 + { } set-nth-unsafe
    ] \ >fixnum inlined?
] unit-test

[ t ] [
    [
        { integer } declare 0 swap
        [
            drop 615949 * 797807 + 20 2^ rem dup 19 2^ -
        ] map
    ] { * + shift rem mod fixnum-mod fixnum* fixnum+ fixnum- } inlined?
] unit-test

[ t ] [
    [
        { fixnum } declare 0 swap
        [
            drop 615949 * 797807 + 20 2^ rem dup 19 2^ -
        ] map
    ] { * + shift rem mod fixnum-mod fixnum* fixnum+ fixnum- >fixnum } inlined?
] unit-test

[ t ] [
    [ hashtable new ] \ new inlined?
] unit-test

[ t ] [
    [ dup hashtable eq? [ new ] when ] \ new inlined?
] unit-test

[ t ] [
    [ { hashtable } declare hashtable instance? ] \ instance? inlined?
] unit-test

[ t ] [
    [ { vector } declare hashtable instance? ] \ instance? inlined?
] unit-test

[ f ] [
    [ { assoc } declare hashtable instance? ] \ instance? inlined?
] unit-test

TUPLE: declared-fixnum { x fixnum } ;

[ t ] [
    [ { declared-fixnum } declare [ 1 + ] change-x ]
    { + fixnum+ >fixnum } inlined?
] unit-test

[ t ] [
    [ { declared-fixnum } declare x>> drop ]
    { slot } inlined?
] unit-test

[ t ] [
    [
        { array } declare length
        1 + dup 100 fixnum> [ 1 fixnum+ ] when
    ] \ fixnum+ inlined?
] unit-test
 
[ t ] [
    [ [ resize-array ] keep length ] \ length inlined?
] unit-test

[ t ] [
    [ dup 0 > [ sqrt ] when ] \ sqrt inlined?
] unit-test

[ t ] [
    [ { utf8 } declare decode-char ] \ decode-char inlined?
] unit-test

[ t ] [
    [ { ascii } declare decode-char ] \ decode-char inlined?
] unit-test

[ t ] [ [ { 1 2 } length ] { length length>> slot } inlined? ] unit-test

[ t ] [
    [
        { integer } declare [ 256 mod ] map
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare [ 0 >= ] map
    ] { >= fixnum>= } inlined?
] unit-test