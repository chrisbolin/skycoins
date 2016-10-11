module Main exposing (..)

import Html.App as App
import AnimationFrame
import Keyboard exposing (KeyCode)
import Model exposing (Model, State(Paused, Flying))
import Msg exposing (Msg(Tick, KeyUp, KeyDown))
import View exposing (view)
import Update exposing (update)
import Subscriptions exposing (subscriptions)


-- Main


main : Program Never
main =
    App.program
        { subscriptions = subscriptions
        , view = view
        , update = update
        , init = ( Model.initialModel, Cmd.none )
        }
