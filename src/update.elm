port module Update exposing (update)

import List exposing (sortBy, reverse)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Model exposing (Model, State(Paused, Flying), View(Game, Leaderboard, AddToLeaderboard))
import Msg exposing (Msg(Tick, KeyUp, KeyDown, GotSavedScore, GotLeaderboard, ChangeName, SubmitName))
import String exposing (toUpper)
import Char exposing (toCode)


port saveScore : ( String, Int ) -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick intervalLengthMs ->
            Model.interate { model | intervalLengthMs = intervalLengthMs }

        GotSavedScore highScore ->
            ( { model | highScore = highScore }, Cmd.none )

        GotLeaderboard leaderboard ->
            ( { model
                | leaderboard = sortBy .score leaderboard |> reverse
              }
            , Cmd.none
            )

        ChangeName newName ->
            -- filter the characters allowed
            ( { model
                | username = (String.filter (\char -> toCode char < 127) newName) |> toUpper
              }
            , Cmd.none
            )

        SubmitName ->
            -- filter the characters allowed
            ( { model | view = Game }, saveScore ( model.username, model.newHighScore ) )

        KeyDown code ->
            case model.view of
                AddToLeaderboard ->
                    case code of
                        13 ->
                            -- Enter
                            -- call update recursively, as we don't need to fire an action
                            update SubmitName model

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    case code of
                        27 ->
                            -- Escape
                            togglePause model

                        32 ->
                            -- Spacebar
                            togglePause model

                        37 ->
                            -- Left
                            ( { model | leftThruster = True }, Cmd.none )

                        38 ->
                            -- Up
                            ( { model | mainEngine = True }, Cmd.none )

                        39 ->
                            -- Right
                            ( { model | rightThruster = True }, Cmd.none )

                        68 ->
                            -- D: Dashboard
                            ( { model | dashboard = not model.dashboard }, Cmd.none )

                        76 ->
                            -- L: Leaderboard
                            ( { model
                                | view =
                                    if model.view == Leaderboard then
                                        Game
                                    else
                                        Leaderboard
                                , state = Paused
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

        KeyUp code ->
            case code of
                37 ->
                    ( { model | leftThruster = False }, Cmd.none )

                38 ->
                    ( { model | mainEngine = False }, Cmd.none )

                39 ->
                    ( { model | rightThruster = False }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


togglePause : Model -> ( Model, Cmd a )
togglePause model =
    ( { model
        | state =
            if model.state == Paused then
                Flying
            else
                Paused
        , view = Game
      }
    , Cmd.none
    )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , Keyboard.ups KeyUp
        , AnimationFrame.diffs Tick
        ]



-- Init


init : ( Model, Cmd Msg )
init =
    ( Model.initialModel, Cmd.none )
