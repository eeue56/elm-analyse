module Docs.Main exposing (..)

import Html exposing (..)
import Docs.Page as Page exposing (Page(..))
import Navigation exposing (Location)
import Docs.MsgDoc
import Docs.Home
import Bootstrap.Navbar
import Docs.Menu
import Docs.Changelog as Changelog
import Docs.Configuration as Configuration
import Docs.Features as Features


main : Program Never Model Msg
main =
    Navigation.program
        OnLocation
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = OnLocation Location
    | MenuMsg Bootstrap.Navbar.State
    | ChangelogMsg Changelog.Msg


type Content
    = HomeContent
    | ChangelogContent Changelog.Model
    | NoContent
    | MessagesContent (Maybe String)
    | ConfigurationContent
    | FeaturesContent


type alias Model =
    { page : Page
    , menu : Bootstrap.Navbar.State
    , content : Content
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( menu, menuCmds ) =
            Bootstrap.Navbar.initialState MenuMsg

        page =
            Page.nextPage location

        ( content, contentCmds ) =
            contentFromPage page
    in
        ( { page = page
          , menu = menu
          , content = content
          }
        , Cmd.batch [ menuCmds, contentCmds ]
        )


contentFromPage : Page -> ( Content, Cmd Msg )
contentFromPage page =
    case page of
        Home ->
            ( HomeContent, Cmd.none )

        Messages x ->
            ( MessagesContent x, Cmd.none )

        Changelog ->
            let
                ( changelogModel, cmds ) =
                    Changelog.init
            in
                ( ChangelogContent changelogModel
                , Cmd.map ChangelogMsg cmds
                )

        Features ->
            ( FeaturesContent, Cmd.none )

        Configuration ->
            ( ConfigurationContent, Cmd.none )

        NotFound ->
            ( NoContent, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MenuMsg s ->
            ( { model | menu = s }
            , Cmd.none
            )

        OnLocation location ->
            init location

        ChangelogMsg x ->
            case model.content of
                ChangelogContent subModel ->
                    ( { model | content = ChangelogContent (Changelog.update x subModel) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ Docs.Menu.menu MenuMsg model.menu
        , body model
        ]


body : Model -> Html Msg
body model =
    case model.content of
        HomeContent ->
            Docs.Home.view

        MessagesContent m ->
            div []
                [ Docs.MsgDoc.view m
                ]

        ChangelogContent x ->
            Changelog.view x |> Html.map ChangelogMsg

        NoContent ->
            div [] [ text "NotFound!" ]

        FeaturesContent ->
            Features.view

        ConfigurationContent ->
            Configuration.view


header : Html msg
header =
    div []
        [ h1 [] [ text "header" ]
        ]


footer : Html msg
footer =
    div []
        [ text "Footer"
        ]
