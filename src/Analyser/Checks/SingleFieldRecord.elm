module Analyser.Checks.SingleFieldRecord exposing (checker)

import Analyser.FileContext exposing (FileContext)
import Elm.Syntax.TypeAnnotation exposing (..)
import Analyser.Configuration exposing (Configuration)
import Analyser.Checks.Base exposing (Checker, keyBasedChecker)
import Analyser.Messages.Types exposing (Message, MessageData(SingleFieldRecord), newMessage)
import ASTUtil.Inspector as Inspector exposing (..)
import Analyser.Messages.Range as Range exposing (RangeContext)
import Elm.Syntax.Range as Syntax


checker : Checker
checker =
    { check = scan
    , shouldCheck = keyBasedChecker [ "SingleFieldRecord" ]
    }


scan : RangeContext -> FileContext -> Configuration -> List Message
scan rangeContext fileContext _ =
    Inspector.inspect
        { defaultConfig | onTypeAnnotation = Post onTypeAnnotation }
        fileContext.ast
        []
        |> List.filter (Tuple.second >> isSingleFieldRecord)
        |> List.map (Tuple.first >> Range.build rangeContext >> SingleFieldRecord fileContext.path)
        |> List.map (newMessage [ ( fileContext.sha1, fileContext.path ) ])


isSingleFieldRecord : RecordDefinition -> Bool
isSingleFieldRecord x =
    List.length x == 1


onTypeAnnotation : TypeAnnotation -> List ( Syntax.Range, RecordDefinition ) -> List ( Syntax.Range, RecordDefinition )
onTypeAnnotation x context =
    findPlainRecords x ++ context


findPlainRecords : TypeAnnotation -> List ( Syntax.Range, RecordDefinition )
findPlainRecords x =
    case x of
        Record fields r ->
            [ ( r, fields ) ]

        _ ->
            []
