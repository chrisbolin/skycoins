module Subscriptions exposing (subscriptions)

import AnimationFrame exposing (diffs)
import Keyboard exposing (KeyCode, ups, downs)
import Model exposing (Model, State(Paused, Flying))
import Msg exposing (Msg(Tick, KeyUp, KeyDown))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ downs KeyDown
        , ups KeyUp
        , diffs Tick
        ]
