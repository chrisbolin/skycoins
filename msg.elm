module Msg exposing (Msg(KeyDown, KeyUp, Tick))

import Keyboard exposing (KeyCode)


type Msg
    = KeyDown KeyCode
    | KeyUp KeyCode
    | Tick Float
