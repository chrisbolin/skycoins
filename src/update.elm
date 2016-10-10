module Update exposing (update)

import AnimationFrame
import Keyboard exposing (KeyCode)
import Model exposing (Model, State(Paused, Flying))
import Msg exposing (Msg(..))
import TouchEvents exposing (TouchEvent(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        startGame
            = { model | state =
                    if model.state == Paused then
                        Flying
                    else
                        Paused
              }
        leftThrust state = ( { model | leftThruster = state }, Cmd.none )
        engine state = ( { model | mainEngine = state }, Cmd.none )
        rightThrust state = ( { model | rightThruster = state }, Cmd.none )
    in case msg of
        Tick intervalLengthMs ->
            ( Model.interate { model | intervalLengthMs = intervalLengthMs }, Cmd.none )

        KeyDown code ->
            case code of
                32 ->
                    -- Spacebar
                    ( startGame, Cmd.none )

                37 ->
                    -- Left
                    leftThrust True

                38 ->
                    -- Up
                    engine True

                39 ->
                    -- Right
                    rightThrust True

                _ ->
                    ( model, Cmd.none )

        KeyUp code ->
            case code of
                37 ->
                    leftThrust False

                38 ->
                    engine False

                39 ->
                    rightThrust False

                82 ->
                    init

                _ ->
                    ( model, Cmd.none )

        StartGame _ ->
            if model.state == Paused then
                let model' = { startGame | tapped = True }
                in ( model', Cmd.none )
            else
                ( model, Cmd.none )
        EngineOn _ ->
            engine True
        EngineOff _ ->
            engine False
        LeftThrustOn _ ->
            leftThrust True
        LeftThrustOff _ ->
            leftThrust False
        RightThrustOn _ ->
            rightThrust True
        RightThrustOff _ ->
            rightThrust False
        


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
