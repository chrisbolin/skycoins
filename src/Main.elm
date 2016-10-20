module Main exposing (..)

import Html.App as App
import Model exposing (Model)
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
