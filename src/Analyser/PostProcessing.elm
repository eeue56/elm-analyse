module Analyser.PostProcessing exposing (..)

import Dict exposing (Dict)
import List exposing (maximum)
import AST.Types exposing (..)
import Analyser.Types exposing (..)
import List.Extra as List
import Tuple2


postProcess : OperatorTable -> File -> File
postProcess table file =
    Debug.log "O" <|
        visit
            { onExpression =
                Just
                    (\context inner expression ->
                        inner <|
                            case expression of
                                Application args ->
                                    fixApplication context args

                                _ ->
                                    expression
                    )
            }
            table
            file


fixApplication : OperatorTable -> List Expression -> Expression
fixApplication operators expressions =
    let
        ops =
            (List.filterMap expressionOperators expressions)
                |> List.map
                    (\x ->
                        ( x
                        , Dict.get x operators
                            |> Maybe.withDefault
                                { operator = x
                                , precedence = 5
                                , direction = Left
                                }
                        )
                    )
                |> highestPrecedence

        fixExprs exps =
            case exps of
                [ x ] ->
                    x

                _ ->
                    Application exps

        doTheThing exps =
            if Dict.isEmpty ops then
                fixExprs exps
            else
                findNextSplit ops exps
                    |> Maybe.map (\( p, o, s ) -> OperatorApplication o (doTheThing p) (doTheThing s))
                    |> Maybe.withDefault (fixExprs exps)
    in
        doTheThing expressions


findNextSplit : Dict String Infix -> List Expression -> Maybe ( List Expression, InfixDirection, List Expression )
findNextSplit dict exps =
    let
        prefix =
            exps
                |> List.takeWhile
                    (\x ->
                        expressionOperators x
                            |> Maybe.andThen (flip Dict.get dict)
                            |> (==) Nothing
                    )

        suffix =
            List.drop (List.length prefix + 1) exps
    in
        if List.isEmpty suffix then
            Nothing
        else
            Just ( prefix, Left, suffix )


highestPrecedence : List ( String, Infix ) -> Dict String Infix
highestPrecedence input =
    let
        maxi =
            input
                |> List.map (Tuple.second >> .precedence)
                |> maximum
    in
        maxi
            |> Maybe.map (\m -> List.filter (Tuple.second >> .precedence >> (==) m) input)
            |> Maybe.withDefault []
            |> Dict.fromList


expressionOperators : Expression -> Maybe String
expressionOperators expression =
    case expression of
        Operator s ->
            Just s

        _ ->
            Nothing


type alias Visitor a =
    { onExpression : Maybe (a -> (Expression -> Expression) -> Expression -> Expression) }


visit : Visitor context -> context -> File -> File
visit visitor context file =
    let
        _ =
            Debug.log "Declaration count" (List.length file.declarations)

        newDeclarations =
            visitDeclarations visitor context file.declarations
    in
        { file | declarations = newDeclarations }


visitDeclarations : Visitor context -> context -> List Declaration -> List Declaration
visitDeclarations visitor context declarations =
    List.map (visitDeclaration visitor context) declarations


visitDeclaration : Visitor context -> context -> Declaration -> Declaration
visitDeclaration visitor context declaration =
    case declaration of
        FuncDecl function ->
            FuncDecl (visitFunctionDecl visitor context function)

        _ ->
            declaration


visitFunctionDecl : Visitor context -> context -> Function -> Function
visitFunctionDecl visitor context function =
    let
        newFunctionDeclaration =
            visitFunctionDeclaration visitor context function.declaration
    in
        { function | declaration = newFunctionDeclaration }


visitFunctionDeclaration : Visitor context -> context -> FunctionDeclaration -> FunctionDeclaration
visitFunctionDeclaration visitor context functionDeclaration =
    let
        newExpression =
            visitExpression visitor context functionDeclaration.expression
    in
        { functionDeclaration | expression = newExpression }


visitExpression : Visitor context -> context -> Expression -> Expression
visitExpression visitor context expression =
    let
        inner =
            visitExpressionInner visitor context
    in
        (visitor.onExpression |> Maybe.withDefault (\context inner expr -> inner expr))
            context
            inner
            expression


visitExpressionInner : Visitor context -> context -> Expression -> Expression
visitExpressionInner visitor context expression =
    let
        subVisit =
            (visitExpression visitor context)
    in
        case expression of
            UnitExpr ->
                expression

            FunctionOrValue string ->
                expression

            PrefixOperator string ->
                expression

            Operator string ->
                expression

            Integer int ->
                expression

            Floatable float ->
                expression

            Literal string ->
                expression

            CharLiteral char ->
                expression

            QualifiedExpr moduleName string ->
                expression

            RecordAccess stringList ->
                expression

            RecordAccessFunction s ->
                expression

            GLSLExpression string ->
                expression

            Application expressionList ->
                expressionList
                    |> List.map subVisit
                    |> Application

            OperatorApplication dir e1 e2 ->
                OperatorApplication dir
                    (subVisit e1)
                    (subVisit e2)

            IfBlock e1 e2 e3 ->
                IfBlock (subVisit e1) (subVisit e2) (subVisit e3)

            TupledExpression expressionList ->
                expressionList
                    |> List.map subVisit
                    |> TupledExpression

            Parentesized e1 ->
                Parentesized (subVisit e1)

            LetBlock declarationList e1 ->
                LetBlock
                    (visitDeclarations visitor context declarationList)
                    (subVisit e1)

            CaseBlock e1 cases ->
                CaseBlock
                    (subVisit e1)
                    (List.map (Tuple2.mapSecond subVisit) cases)

            Lambda patternList e1 ->
                Lambda patternList (subVisit e1)

            RecordExpr expressionStringList ->
                expressionStringList
                    |> List.map (Tuple2.mapSecond subVisit)
                    |> RecordExpr

            ListExpr expressionList ->
                ListExpr (List.map subVisit expressionList)

            RecordUpdate string expressionStringList ->
                expressionStringList
                    |> List.map (Tuple.mapSecond subVisit)
                    |> (RecordUpdate string)
