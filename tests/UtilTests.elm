module UtilTests exposing (..)

import Parser.Util as Parser exposing (moreThanIndentWhitespace, exactIndentWhitespace)
import Parser.Types exposing (..)
import Test exposing (..)
import Expect
import CombineTestUtil exposing (..)


all : Test
all =
    describe "ImportTest"
        [ test "no whitespace" <|
            \() ->
                parseFullStringState emptyState "" moreThanIndentWhitespace
                    |> Expect.equal Nothing
        , test "just whitespace" <|
            \() ->
                parseFullStringState emptyState " " moreThanIndentWhitespace
                    |> Expect.equal (Just " ")
        , test "with newline and higher indent 1" <|
            \() ->
                parseFullStringState emptyState " \n" moreThanIndentWhitespace
                    |> Expect.equal Nothing
        , test "with newline and higher indent 2" <|
            \() ->
                parseFullStringState emptyState "\n  " moreThanIndentWhitespace
                    |> Expect.equal (Just "\n  ")
        , test "with newline and higher indent 2" <|
            \() ->
                parseFullStringState emptyState " \n " moreThanIndentWhitespace
                    |> Expect.equal (Just " \n ")
        , test "with newline and higher indent 3" <|
            \() ->
                parseFullStringState (emptyState |> pushIndent 1) " \n " moreThanIndentWhitespace
                    |> Expect.equal Nothing
        , test "with newline and higher indent 4" <|
            \() ->
                parseFullStringState (emptyState |> pushIndent 1) " \n  " moreThanIndentWhitespace
                    |> Expect.equal (Just " \n  ")
        , test "exactIndentWhitespace" <|
            \() ->
                parseFullStringState emptyState " \n" exactIndentWhitespace
                    |> Expect.equal (Just " \n")
        , test "exactIndentWhitespace multi line" <|
            \() ->
                parseFullStringState emptyState " \n      \n" exactIndentWhitespace
                    |> Expect.equal (Just " \n      \n")
        , test "exactIndentWhitespace too much" <|
            \() ->
                parseFullStringState emptyState " \n " exactIndentWhitespace
                    |> Expect.equal Nothing
        , test "exactIndentWhitespace with comments" <|
            \() ->
                parseFullStringState emptyState "-- foo\n  --bar\n" exactIndentWhitespace
                    |> Expect.equal (Just "-- foo\n  --bar\n")
        , test "exactIndentWhitespace with comments 2" <|
            \() ->
                parseFullStringState emptyState "\n--x\n{-| foo \n-}\n" exactIndentWhitespace
                    |> Expect.equal (Just "\n--x\n{-| foo \n-}\n")
        , test "moreThanIndentWhitespace with multiple new lines" <|
            \() ->
                parseFullStringState (emptyState |> pushIndent 2) "\n  \n    \n\n   " moreThanIndentWhitespace
                    |> Expect.equal (Just "\n  \n    \n\n   ")
        , test "moreThanIndentWhitespace with comments" <|
            \() ->
                parseFullStringState emptyState "\n --foo\n " moreThanIndentWhitespace
                    |> Expect.equal (Just "\n --foo\n ")
        , test "moreThanIndentWhitespace with comments" <|
            \() ->
                parseFullStringState emptyState "\n --bar\n " moreThanIndentWhitespace
                    |> Expect.equal (Just "\n --bar\n ")
        , test "exactIndentWhitespace with multiple new lines" <|
            \() ->
                parseFullStringState (emptyState |> pushIndent 2) "\n  \n    \n\n  " exactIndentWhitespace
                    |> Expect.equal (Just "\n  \n    \n\n  ")
        , test "exactIndentWhitespace with multiple new lines" <|
            \() ->
                parseFullStringState emptyState "-- bar\n " moreThanIndentWhitespace
                    |> Expect.equal (Just "-- bar\n ")
        ]