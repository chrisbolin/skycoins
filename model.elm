module Model exposing (Model, tick)

import Utils exposing (floatModulo)
import Config exposing (config)

type alias Model =
  {
    paused: Bool,
    mainEngine: Bool,
    rightThruster: Bool,
    leftThruster: Bool,
    x: Float,
    y: Float,
    theta: Float,
    dx: Float,
    dy: Float,
    dtheta: Float,
    coin :
    {
      x: Float,
      y: Float
    },
    intervalLengthMs: Float
  }

type State = Flying | Crashed | Landed | Paused

determineState : Model -> State
determineState model =
  if model.paused then Paused
  else if model.y > 0 then Flying
  else if abs model.dy > 10 then Crashed
  else if abs model.dx > 15 then Crashed
  else if (model.theta > 30) && (model.theta < 330) then Crashed
  else Landed

tick : Model -> Model
tick model =
  model |> vehicle |> coin

coin : Model -> Model
coin model =
  model

vehicle : Model -> Model
vehicle model =
  let
    -- scaling
    intervalLength = model.intervalLengthMs / 100
    thetaRad = degrees model.theta
    state = determineState model
    dyEngine = if model.mainEngine then config.engine * intervalLength * cos thetaRad else 0
    dxEngine = if model.mainEngine then config.engine * intervalLength * sin thetaRad else 0
    -- computed
    dy1 =
      (if state == Flying then model.dy - config.gravity * intervalLength else 0) -- gravity / floor
      + dyEngine
    y1 = max 0 (model.y + dy1 * intervalLength) -- don't go "under" the ground
    dx1 = if state == Flying then (model.dx + dxEngine) else model.dx / config.correction.dx
    x1 = (floatModulo (model.x + dx1 * intervalLength) 200)
    dtheta1 = if state == Flying then
      ( if model.leftThruster == model.rightThruster then model.dtheta
        else if model.leftThruster then model.dtheta - config.thrusters * intervalLength
        else if model.rightThruster then model.dtheta + config.thrusters * intervalLength
        else model.dtheta
        )
      else 0
    theta1 = if state == Flying then floatModulo (model.theta + dtheta1 * intervalLength) 360
      else if model.theta < 180 then (model.theta + 0) / config.correction.theta
      else (model.theta + 360) / config.correction.theta
  in
    case state of
      Paused ->
        model
      Crashed ->
        {model
          | paused = True
          , dy = 0
          , y = 10
          , x = 50
          , dx = 0
          , dtheta = 0
          , theta = 0
        }
      _ ->
        {model
          | dy = dy1
          , y = y1
          , x = x1
          , dx = dx1
          , dtheta = dtheta1
          , theta = theta1
          }
