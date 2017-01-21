module Parser.Typings exposing (..)

import Combine exposing (..)
import Parser.Tokens exposing (functionName, typeName)
import Parser.TypeReference exposing (typeReference)
import Parser.Types exposing (..)
import Parser.Util exposing (moreThanIndentWhitespace)


typeDeclaration : Parser State Type
typeDeclaration =
    succeed Type
        <*> (typePrefix *> typeName)
        <*> genericList
        <*> (maybe moreThanIndentWhitespace *> string "=" *> maybe moreThanIndentWhitespace *> valueConstructors)


valueConstructors : Parser State (List ValueConstructor)
valueConstructors =
    sepBy (string "|") (maybe moreThanIndentWhitespace *> valueConstructor <* maybe moreThanIndentWhitespace)


valueConstructor : Parser State ValueConstructor
valueConstructor =
    succeed ValueConstructor
        <*> typeName
        <*> many (moreThanIndentWhitespace *> typeReference)


typeAlias : Parser State TypeAlias
typeAlias =
    succeed TypeAlias
        <*> (typeAliasPrefix *> typeName)
        <*> genericList
        <*> (maybe moreThanIndentWhitespace *> string "=" *> maybe moreThanIndentWhitespace *> typeReference)


genericList : Parser State (List String)
genericList =
    many (moreThanIndentWhitespace *> functionName)


typePrefix : Parser State String
typePrefix =
    string "type" *> moreThanIndentWhitespace


typeAliasPrefix : Parser State String
typeAliasPrefix =
    typePrefix *> string "alias" *> moreThanIndentWhitespace