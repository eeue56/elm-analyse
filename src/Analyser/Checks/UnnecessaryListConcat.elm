module Analyser.Checks.UnnecessaryListConcat exposing (checker)

import Analyser.Messages.Range as Range exposing (Range, RangeContext)
import Elm.Syntax.Expression exposing (..)
import Analyser.FileContext exposing (FileContext)
import Analyser.Messages.Types exposing (Message, MessageData(UnnecessaryListConcat), newMessage)
import ASTUtil.Inspector as Inspector exposing (Order(Post), defaultConfig)
import Analyser.Configuration exposing (Configuration)
import Analyser.Checks.Base exposing (Checker, keyBasedChecker)


checker : Checker
checker =
    { check = scan
    , shouldCheck = keyBasedChecker [ "UnnecessaryListConcat" ]
    }


type alias Context =
    List Range


scan : RangeContext -> FileContext -> Configuration -> List Message
scan rangeContext fileContext _ =
    Inspector.inspect
        { defaultConfig
            | onExpression = Post (onExpression rangeContext)
        }
        fileContext.ast
        []
        |> List.map (UnnecessaryListConcat fileContext.path)
        |> List.map (newMessage [ ( fileContext.sha1, fileContext.path ) ])


isListExpression : Expression -> Bool
isListExpression ( _, inner ) =
    case inner of
        ListExpr _ ->
            True

        _ ->
            False


onExpression : RangeContext -> Expression -> Context -> Context
onExpression rangeContext ( r, inner ) context =
    case inner of
        Application [ ( _, QualifiedExpr [ "List" ] "concat" ), ( _, ListExpr args ) ] ->
            if List.all isListExpression args then
                Range.build rangeContext r :: context
            else
                context

        _ ->
            context
