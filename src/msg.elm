module Msg exposing (Msg(..))

import Keyboard exposing (KeyCode)
import Model exposing (Leaderboard)


type Msg
    = KeyDown KeyCode
    | KeyUp KeyCode
    | Tick Float
    | GotSavedScore Int
    | GotLeaderboard Leaderboard
