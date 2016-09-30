module Model exposing (tick)

import Utils exposing (floatModulo)
import Config exposing (config)

type State = Flying | Crashed | Landed

determineState model =
  if model.y > 0 then Flying
  else if abs model.dy > 10 then Crashed
  else if abs model.dx > 15 then Crashed
  else if (model.theta > 30) && (model.theta < 330) then Crashed
  else Landed

tick model intervalLengthMs =
  let
    -- scaling
    intervalLength = intervalLengthMs / 100
    thetaRad = degrees model.theta
    state = determineState model
    dyEngine = if model.mainEngine then config.engine * intervalLength * cos thetaRad else 0
    dxEngine = if model.mainEngine then config.engine * intervalLength * sin thetaRad else 0
    -- computed
    dy1 =
      (if state == Flying then model.dy - config.gravity * intervalLength else 0) -- gravity / floor
      + dyEngine
    y1 = max 0 (model.y + dy1 * intervalLength) -- don't go "under" the ground
    dx1 = if state == Flying then (model.dx + dxEngine) else 0
    x1 = (floatModulo (model.x + dx1 * intervalLength) 200)
    dtheta1 = if state == Flying then
      ( if model.leftThruster == model.rightThruster then model.dtheta
        else if model.leftThruster then model.dtheta - config.thrusters * intervalLength
        else if model.rightThruster then model.dtheta + config.thrusters * intervalLength
        else model.dtheta
        )
      else 0
    theta1 = if state == Flying then floatModulo (model.theta + dtheta1 * intervalLength) 360 else 0
  in
    case state of
      Crashed ->
        {model
          | dy = 0
          , y = 100
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
