module Model exposing (Model, State(..), Goal(..), interate, initialModel, viewportMaxY, getHighScore, GameMode(..))

import Utils exposing (floatModulo)
import Config exposing (config)
import LocalStorage
import Json.Encode
import String


type State
    = Flying
    | Crashed
    | Landed
    | Paused
    | GameOver


type Goal
    = Coin
    | Pad

type GameMode
    = NormalMode
    | TimeTrialMode


type alias Model =
    { state : State
    , goal : Goal
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
    , previousScore : Int
    , intervalLengthMs : Float
    , tapped : Bool
    , mode : GameMode
    , highScore : Int
    , window :
        { width : Int
        , height : Int
        }
    , padx : Float
    , pady : Float
    , padDirection : Int -- -1 is Left, 1 is Right
    , timeRemaining : Float
    , timeLimit : Float
    , playing : Bool
    , movingPad : Bool
    }

getHighScore : String -> String -> Int
getHighScore default key =
    Result.withDefault 0
        <| String.toInt
            <| String.fromList
                <| String.foldr (\c acc -> if c == '"' then acc else c :: acc) []
                    <| Maybe.withDefault default <| LocalStorage.get key

initialModel : Model
initialModel =
    { state = Paused
    , goal = Coin
    , score = 0
    , mainEngine = False
    , rightThruster = False
    , leftThruster = False
    , x = 140
    , y = 60
    , theta = 0
    , dx = 0
    , dy = 0
    , dtheta = 0
    , intervalLengthMs = 0
    , coin =
        { x = 111.5
        , y = 65.6
        }
    , debris =
        { x = 0
        , y = 0
        , show = False
        }
    , padx = 40
    , pady = 10
    , padDirection = 1
    , timeRemaining = 0
    , timeLimit = 120
    , mode = NormalMode
    -- TO CACHE
    , highScore = getHighScore "0" "highscore"
    , previousScore = 0
    , tapped = False
    , window =
        { width = 0
        , height = 0
        }
    , playing = False
    , movingPad = False
    }


interate : Model -> Model
interate model =
    if model.state /= Crashed then
        model |> time |> state |> goal |> vehicle |> pad |> coin
    else
        model

time : Model -> Model
time model =
    --if round timeRemaining <= 0 then
    if model.mode == TimeTrialMode && model.timeRemaining <= 0 then
        crashedModel { initialModel
            | previousScore = model.score
            , tapped = model.tapped
            , window = model.window
            , movingPad = model.movingPad
        }
    else
        model

state : Model -> Model
state model =
    if model.state == Paused then
        model
    else if model.state == Crashed then
        { model | state = Paused }
    else if model.y > (config.vehicle.y / 2 + config.base.y) then -- Above sea level
        { model | state = Flying }
    else if model.x < (model.padx - 5) || model.x > (model.padx + config.pad.width) then -- Outside the pad
        { model | state = Crashed }
    else if abs model.dy > 15 then -- Max vertical speed not to crash
        { model | state = Crashed }
    else if abs model.dx > 15 then -- Max horizontal speed not to crash
        { model | state = Crashed }
    else if (model.theta > 30) && (model.theta < 330) then
        { model | state = Crashed }
    else -- Landed inside the pad
        { model | state = Landed }


goal : Model -> Model
goal model =
    if model.state == Crashed then
        { model | goal = Coin }
    else if (model.state == Landed && abs model.dx < 0.5) then
        { model | goal = Coin }
    else
        model


coinCollected : Model -> Bool
coinCollected model =
    if model.goal == Pad then
        False
    else if (model.x - model.coin.x |> abs) > config.vehicle.x / 2 then
        False
    else if (model.y - model.coin.y |> abs) > config.vehicle.y then
        False
    else
        True


viewportMaxY : Model -> Float
viewportMaxY model = if model.tapped then 200 else 100

coin : Model -> Model
coin model =
    if coinCollected model then
        let
            newScore = model.score + 100
            newHigh = max newScore <| getHighScore "0" "highscore"
            -- Dummy line of code to persist high score to LocalStorage
            a = LocalStorage.set "highscore" <| Json.Encode.string (toString newHigh)
        in { model
            | coin =
                { x = floatModulo (model.coin.x + 71) 200
                , y = clamp (config.base.y + config.coin.y) (viewportMaxY model) (floatModulo (model.coin.y + 20) (viewportMaxY model))
                }
            , score = newScore
            , goal = Pad
            , highScore = newHigh
        }
    else
        model

crashedModel model =
    { model | highScore = getHighScore "0" "highscore"
    }


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
            max (config.vehicle.y / 2 + config.base.y) (model.y + dy1 * intervalLength)

        -- don't go "under" the ground
        dx1 =
            if model.state == Flying then
                (model.dx + dxEngine)
            else
                model.dx / config.correction.dx

        x1 =
            if model.state == Landed && abs dx1 < toFloat model.score / 1000 then
                model.x + (basePadIncrease model) * toFloat model.padDirection
            else
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
                crashedModel { initialModel
                    | debris =
                        { x = x1
                        , y = y1
                        , show = True
                        }
                    , previousScore = model.score
                    , tapped = model.tapped
                    , window = model.window
                    , playing = False
                    , movingPad = model.movingPad
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

basePadIncrease : Model -> Float
basePadIncrease model =
    if model.movingPad then
        0.05 + toFloat model.score/padScoreFractional
    else
        0

padScoreFractional : Float
padScoreFractional = 8000

pad : Model -> Model
pad model =
    if model.state == Paused then
        model
    else
        let
            -- scaling
            intervalLength =
                model.intervalLengthMs / 100
            dx = basePadIncrease model
            padx' = model.padx + dx * toFloat model.padDirection
            model' = { model | padx = padx' }
            direction =
                if (padx' + config.pad.width) > 200 - 10 then
                    -1
                else if padx' < 10 then
                    1
                else
                    model.padDirection
        in
            { model' | padDirection = direction }

