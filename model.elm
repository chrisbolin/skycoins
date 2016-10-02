module Model exposing (Model, State(..), interate, initialModel)

import Utils exposing (floatModulo)
import Config exposing (config)


type State
    = Flying
    | Crashed
    | Landed
    | Paused


type alias Model =
    { state : State
    , score : Int
    , mainEngine : Bool
    , rightThruster : Bool
    , leftThruster : Bool
    , x : Float
    , y : Float
    , theta : Float
    , dx : Float
    , dy : Float
    , dtheta : Float
    , coin :
        { x : Float
        , y : Float
        }
    , debris :
        { x : Float
        , y : Float
        , show : Bool
        }
    , intervalLengthMs : Float
    }


initialModel : Model
initialModel =
    { state = Paused
    , score = 0
    , mainEngine = False
    , rightThruster = False
    , leftThruster = False
    , x = 100
    , y = 20
    , theta = 0
    , dx = 0
    , dy = 0
    , dtheta = 0
    , intervalLengthMs = 0
    , coin =
        { x = 150
        , y = 50
        }
    , debris =
        { x = 0
        , y = 0
        , show = False
        }
    }


state : Model -> Model
state model =
    if model.state == Paused then
        model
    else if model.state == Crashed then
        { model | state = Paused }
    else if model.y > (config.vehicle.y / 2) then
        { model | state = Flying }
    else if abs model.dy > 10 then
        { model | state = Crashed }
    else if abs model.dx > 15 then
        { model | state = Crashed }
    else if (model.theta > 30) && (model.theta < 330) then
        { model | state = Crashed }
    else
        { model | state = Landed }


coinCollected : Model -> Bool
coinCollected model =
    if (model.x - model.coin.x |> abs) > config.vehicle.x / 2 then
        False
    else if (model.y - model.coin.y |> abs) > config.vehicle.y then
        False
    else
        True


interate : Model -> Model
interate model =
    model |> state |> vehicle |> coin


coin : Model -> Model
coin model =
    if coinCollected model then
        { model
            | coin =
                { x = floatModulo (model.coin.x + 47) 200
                , y = floatModulo (model.coin.y + 27) 100
                }
            , score = model.score + 100
        }
    else
        model


vehicle : Model -> Model
vehicle model =
    let
        -- scaling
        intervalLength =
            model.intervalLengthMs / 100

        thetaRad =
            degrees model.theta

        dyEngine =
            if model.mainEngine then
                config.engine * intervalLength * cos thetaRad
            else
                0

        dxEngine =
            if model.mainEngine then
                config.engine * intervalLength * sin thetaRad
            else
                0

        -- computed
        dy1 =
            (if model.state == Flying then
                model.dy - config.gravity * intervalLength
             else
                0
            )
                + dyEngine

        y1 =
            max (config.vehicle.y / 2) (model.y + dy1 * intervalLength)

        -- don't go "under" the ground
        dx1 =
            if model.state == Flying then
                (model.dx + dxEngine)
            else
                model.dx / config.correction.dx

        x1 =
            (floatModulo (model.x + dx1 * intervalLength) 200)

        dtheta1 =
            if model.state == Flying then
                (if model.leftThruster == model.rightThruster then
                    model.dtheta
                 else if model.leftThruster then
                    model.dtheta - config.thrusters * intervalLength
                 else if model.rightThruster then
                    model.dtheta + config.thrusters * intervalLength
                 else
                    model.dtheta
                )
            else
                0

        theta1 =
            if model.state == Flying then
                floatModulo (model.theta + dtheta1 * intervalLength) 360
            else if model.theta < 180 then
                (model.theta + 0) / config.correction.theta
            else
                (model.theta + 360) / config.correction.theta
    in
        case model.state of
            Paused ->
                model

            Crashed ->
                { model
                    | dy = 0
                    , y = 50
                    , x = 50
                    , dx = 0
                    , dtheta = 0
                    , theta = 0
                    , score = 0
                    , debris =
                        { x = x1
                        , y = y1
                        , show = True
                        }
                }

            _ ->
                { model
                    | dy = dy1
                    , y = y1
                    , x = x1
                    , dx = dx1
                    , dtheta = dtheta1
                    , theta = theta1
                    , debris =
                        { show = False
                        , x = 0
                        , y = 0
                        }
                }
