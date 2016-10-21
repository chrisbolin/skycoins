module Model exposing (Model, Leaderboard, LeaderboardEntry, State(..), Goal(..), View(..), interate, initialModel)

import List exposing (head, reverse)
import Utils exposing (floatModulo)
import Config exposing (config)


type View
    = Game
    | Leaderboard
    | AddToLeaderboard


type State
    = Flying
    | Crashed
    | Landed
    | Paused


type Goal
    = Coin
    | Pad


type alias LeaderboardEntry =
    { score : Int
    , username : String
    }


type alias Leaderboard =
    List LeaderboardEntry


type alias Model =
    { state : State
    , view : View
    , goal : Goal
    , score : Int
    , newHighScore : Int
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
    , highScore : Int
    , intervalLengthMs : Float
    , leaderboard : Leaderboard
    , username : String
    }


initialModel : Model
initialModel =
    { state = Paused
    , view = Game
    , goal = Coin
    , score = 0
    , newHighScore = 0
    , mainEngine = False
    , rightThruster = False
    , leftThruster = False
    , x = 140
    , y = 40
    , theta = 0
    , dx = 0
    , dy = 0
    , dtheta = 0
    , intervalLengthMs = 0
    , highScore = 0
    , coin =
        { x = 111.5
        , y = 65.6
        }
    , debris =
        { x = 0
        , y = 0
        , show = False
        }
    , leaderboard = []
    , username = ""
    }


interate : Model -> ( Model, Cmd a )
interate model =
    model |> state |> goal |> vehicle |> coin |> highScore


state : Model -> Model
state model =
    case model.state of
        Paused ->
            model

        _ ->
            if model.state == Crashed then
                { model | state = Paused, score = 0 }
            else if model.y > (config.vehicle.y / 2 + config.base.y) then
                { model | state = Flying }
            else if model.x < 45 || model.x > 50 + config.pad.x then
                { model | state = Crashed }
            else if abs model.dy > 15 then
                { model | state = Crashed }
            else if abs model.dx > 20 then
                { model | state = Crashed }
            else if (model.theta > 30) && (model.theta < 330) then
                { model | state = Crashed }
            else
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


coin : Model -> Model
coin model =
    if coinCollected model then
        { model
            | coin =
                { x = floatModulo (model.coin.x + 71) 200
                , y = clamp (config.base.y + config.coin.y) 100 (floatModulo (model.coin.y + 39) 100)
                }
            , score = model.score + 100
            , goal = Pad
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
            max (config.vehicle.y / 2 + config.base.y) (model.y + dy1 * intervalLength)

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
                ((model.theta + 0) / config.correction.theta) |> floor |> toFloat
            else
                ((model.theta + 360) / config.correction.theta) |> round |> toFloat
    in
        case model.state of
            Paused ->
                model

            Crashed ->
                { initialModel
                    | debris =
                        { x = x1
                        , y = y1
                        , show = True
                        }
                        -- preserve and persist
                    , username = model.username
                    , state = model.state
                    , highScore = model.highScore
                    , score = model.score
                    , leaderboard = model.leaderboard
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


highScore : Model -> ( Model, Cmd a )
highScore model =
    let
        highScore =
            max model.score model.highScore

        updatedModel =
            { model | highScore = highScore }
    in
        if (model.state == Crashed) then
            if (model.score > leaderboardThreshold model) then
                ( { updatedModel | view = AddToLeaderboard, newHighScore = model.score }, Cmd.none )
            else
                ( updatedModel, Cmd.none )
        else
            ( model, Cmd.none )


leaderboardThreshold : Model -> Int
leaderboardThreshold model =
    let
        last =
            Maybe.withDefault
                { score = 0, username = "" }
                (model.leaderboard |> reverse |> head)
    in
        last.score
