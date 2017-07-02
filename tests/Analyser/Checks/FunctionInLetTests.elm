module Analyser.Checks.FunctionInLetTests exposing (all)

import Analyser.Checks.FunctionInLet as FunctionInLet
import Test exposing (Test)
import Analyser.Checks.CheckTestUtil as CTU
import Analyser.Messages.Types exposing (Message, MessageData(FunctionInLet), newMessage)
import Analyser.Messages.Range as Range


functionInLet : ( String, String, List MessageData )
functionInLet =
    ( "functionInLet"
    , """module Bar exposing (..)

foo x =
  let
      y z =
        z
  in
    y x
"""
    , [ FunctionInLet "./foo.elm" <|
            Range.manual
                { start = { row = 4, column = 6 }, end = { row = 4, column = 7 } }
                { start = { row = 4, column = 5 }, end = { row = 4, column = 6 } }
      ]
    )


curriedValueInLet : ( String, String, List MessageData )
curriedValueInLet =
    ( "curriedValueInLet"
    , """module Bar exposing (..)

foo x =
  let
      y = List.map ((+) 1)
  in
    y x
"""
    , []
    )


all : Test
all =
    CTU.build "Analyser.Checks.FunctionInLet"
        FunctionInLet.checker
        [ functionInLet
        , curriedValueInLet
        ]
