module Subscriptions exposing (subscriptions, initialSizeCmd)

import AnimationFrame exposing (diffs)
import Keyboard exposing (KeyCode, ups, downs)
import Model exposing (Model, State(Paused, Flying))
import Msg exposing (Msg(Tick, KeyUp, KeyDown, WindowResize, DummyMsg))
import Window
import Task


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ downs KeyDown
        , ups KeyUp
        , diffs Tick
        , (Window.resizes sizeToMsg)
        ]

sizeToMsg : Window.Size -> Msg
sizeToMsg size =
  WindowResize (size.width, size.height)

initialSizeCmd : Cmd Msg
initialSizeCmd =
  Task.perform (\_ -> DummyMsg) sizeToMsg Window.size