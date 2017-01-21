module PatternTests exposing (..)

import CombineTestUtil exposing (..)
import Expect
import Parser.Types as Types exposing (..)
import Test exposing (..)
import Parser.Patterns as Parser exposing (..)


all : Test
all =
    describe "PatternTests"
        [ test "all pattern" <|
            \() ->
                parseFullStringState emptyState "_" Parser.pattern
                    |> Expect.equal (Just AllPattern)
        , test "unit pattern" <|
            \() ->
                parseFullStringState emptyState "()" Parser.pattern
                    |> Expect.equal (Just UnitPattern)
        , test "string pattern" <|
            \() ->
                parseFullStringState emptyState "\"Foo\"" Parser.pattern
                    |> Expect.equal (Just (StringPattern "Foo"))
        , test "non cons pattern pattern" <|
            \() ->
                parseFullStringState emptyState "(X x)" Parser.nonConsPattern
                    |> Expect.equal (Just (TuplePattern ([ NamedPattern [] "X" ([ VarPattern "x" ]) ])))
        , test "parentiszed pattern" <|
            \() ->
                parseFullStringState emptyState "(X x) :: xs" Parser.pattern
                    |> Expect.equal (Just (UnConsPattern (TuplePattern ([ NamedPattern [] "X" ([ VarPattern "x" ]) ])) (VarPattern "xs")))
        , test "int pattern" <|
            \() ->
                parseFullStringState emptyState "1" Parser.pattern
                    |> Expect.equal (Just (IntPattern 1))
        , test "uncons pattern" <|
            \() ->
                parseFullStringState emptyState "n :: tail" Parser.pattern
                    |> Expect.equal (Just (UnConsPattern (VarPattern "n") (VarPattern "tail")))
        , test "list pattern" <|
            \() ->
                parseFullStringState emptyState "[1]" Parser.pattern
                    |> Expect.equal (Just (ListPattern [ IntPattern 1 ]))
        , test "float pattern" <|
            \() ->
                parseFullStringState emptyState "1.2" Parser.pattern
                    |> Expect.equal (Just (FloatPattern 1.2))
        , test "record pattern" <|
            \() ->
                parseFullStringState emptyState "{a,b}" Parser.pattern
                    |> Expect.equal (Just (RecordPattern [ "a", "b" ]))
        , test "named pattern" <|
            \() ->
                parseFullStringState emptyState "True" Parser.namedPattern
                    |> Expect.equal (Just (NamedPattern [] "True" []))
        , test "tuple pattern" <|
            \() ->
                parseFullStringState emptyState "(a,{b,c},())" Parser.pattern
                    |> Expect.equal
                        (Just
                            (TuplePattern
                                [ VarPattern "a"
                                , RecordPattern [ "b", "c" ]
                                , UnitPattern
                                ]
                            )
                        )
        , test "destructure pattern" <|
            \() ->
                parseFullStringState emptyState "Set x" Parser.pattern
                    |> Expect.equal (Just (NamedPattern [] "Set" [ VarPattern "x" ]))
        , test "tuple pattern 2" <|
            \() ->
                parseFullStringState emptyState "(model, cmd)" Parser.pattern
                    |> Expect.equal
                        (Just
                            (TuplePattern
                                [ VarPattern "model"
                                , VarPattern "cmd"
                                ]
                            )
                        )
        , test "tuple pattern" <|
            \() ->
                parseFullStringState emptyState "({model,context} as appState)" Parser.pattern
                    |> Expect.equal
                        (Just
                            (AsPattern
                                (RecordPattern [ "model", "context" ])
                                "appState"
                            )
                        )
        ]