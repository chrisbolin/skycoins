port module Subscriptions exposing (subscriptions)

import AnimationFrame exposing (diffs)
import Keyboard exposing (KeyCode, ups, downs)
import Model exposing (Model, State(Paused, Flying), Leaderboard)
import Msg exposing (Msg(Tick, KeyUp, KeyDown, GotSavedScore, GotLeaderboard))


port getSavedScore : (Int -> msg) -> Sub msg


port getLeaderboard : (Leaderboard -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ downs KeyDown
        , ups KeyUp
        , diffs Tick
        , getSavedScore GotSavedScore
        , getLeaderboard GotLeaderboard
        ]
