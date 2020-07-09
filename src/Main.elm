module Main exposing (..)

import Animator
import Animator.Css
import Animator.Inline
import Browser
import Color
import Html exposing (..)
import Html.Attributes as Attr exposing (src)
import Html.Events as Events exposing (onClick)
import Process
import Task
import Time



---- MODEL ----


type alias Model =
    { checked : Animator.Timeline Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { checked = Animator.init False }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | Toggle Bool
    | Tick Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Toggle newState ->
            ( { model
                | checked =
                    model.checked
                        |> Animator.go Animator.verySlowly newState
              }
            , Cmd.none
            )

        Tick newTime ->
            ( model
                |> Animator.update newTime animator
            , Cmd.none
            )


animator : Animator.Animator Model
animator =
    Animator.animator
        -- *NOTE*  We're using `the Animator.Css.watching` instead of `Animator.watching`.
        -- Instead of asking for a constant stream of animation frames, it'll only ask for one
        -- and we'll render the entire css animation in that frame.
        |> Animator.Css.watching
            .checked
            (\newChecked model ->
                { model | checked = newChecked }
            )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        x =
            Animator.current model.checked
    in
    div []
        [ div []
            [ button [ onClick (Toggle (not x)) ] [ text "Toggle background color" ]
            ]
        , Animator.Css.div model.checked
            [ Animator.Css.backgroundColor <|
                \checked ->
                    if checked then
                        Color.rgb255 255 96 96

                    else
                        Color.white
            ]
            []
            [ img [ src "/logo.svg" ] []
            , h1 [] [ text "Your Elm App is working!" ]
            ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions =
            \model ->
                animator
                    |> Animator.toSubscription Tick model
        }
