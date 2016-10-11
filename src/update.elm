module Update exposing (update)

import AnimationFrame
import Keyboard exposing (KeyCode)
import Model exposing (Model, State(..))
import Msg exposing (Msg(..))
import TouchEvents exposing (TouchEvent(..))
import Window


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
                    let model' = { startGame | tapped = False }
                    in
                        if model.state == Crashed then
                            ( model', Cmd.none )
                        else
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
        TouchOn event ->
            let
                pct = 100 * (event.clientX / (toFloat model.window.width))
            in
                if pct >= 0 && pct < 20 then
                    leftThrust True
                else if pct >= 20 && pct < 40 then
                    ( { model | leftThruster = True, mainEngine = True }, Cmd.none )
                else if pct >= 40 && pct < 60 then
                    engine True
                else if pct >= 60 && pct < 80 then
                    ( { model | rightThruster = True, mainEngine = True }, Cmd.none )
                else
                    rightThrust True
        
        TouchOff _ ->
            ( { model | leftThruster = False, rightThruster = False, mainEngine = False }, Cmd.none )
        
        --LeftThrustOn _ ->
        --    leftThrust True
        --LeftThrustOff _ ->
        --    leftThrust False
        --RightThrustOn _ ->
        --    rightThrust True
        --RightThrustOff _ ->
        --    rightThrust False

        WindowResize (w,h) ->
            let
                window' =
                    { width = w
                    , height = h
                }
            in
                ( { model | window = window' }, Cmd.none )
        _ ->
            ( model, Cmd.none )
        


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
