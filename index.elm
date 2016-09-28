import Html exposing (Html, button, div, text, h6)
import Html.App as App
import Html.Attributes exposing (style)
import AnimationFrame
import Debug exposing (log)
import Keyboard exposing (KeyCode)
import Svg exposing (svg, circle, line, rect, use)
import Svg.Attributes exposing (viewBox, width, x, y, x1, y1, x2, y2, xlinkHref, stroke, transform)

import Utils exposing (floatModulo)

config =
  { vehicle =
    { x = 25
    , y = 13
    }
  , gravity = 2
  , engine = 2.9 -- up
  , thrusters = 2 -- left/right
  }

-- Main

main = App.program
  {
   subscriptions = subscriptions,
   view = view,
   update = update,
   init = init
 }

-- Model

type alias Model =
  {
    mainEngine: Bool,
    rightThruster: Bool,
    leftThruster: Bool,
    x: Float,
    y: Float,
    theta: Float,
    dx: Float,
    dy: Float,
    dtheta: Float
  }

-- Update

type Msg
  = KeyDown KeyCode
  | KeyUp KeyCode
  | Tick Float

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick intervalLengthMs ->
      let
        -- scaling
        intervalLength = intervalLengthMs / 100
        thetaRad = degrees model.theta
        -- computed
        dy1 =
          (if model.y > 0 then model.dy - config.gravity * intervalLength else 0) -- gravity / floor
          + (if model.mainEngine then config.engine * intervalLength * cos thetaRad else 0)
        y1 = max 0 (model.y + dy1 * intervalLength)
        dx1 = if y1 > 0 then
          ( model.dx
            + (if model.mainEngine then config.engine * intervalLength * sin thetaRad else 0)
            )
          else 0
        x1 = (floatModulo (model.x + dx1 * intervalLength + config.vehicle.x/2) 200) - config.vehicle.x/2
        dtheta1 = if y1 > 0 then
          ( if model.leftThruster == model.rightThruster then model.dtheta
            else if model.leftThruster then model.dtheta - config.thrusters * intervalLength
            else if model.rightThruster then model.dtheta + config.thrusters * intervalLength
            else model.dtheta
            )
          else 0
        theta1 = if y1 > 0 then model.theta + dtheta1 * intervalLength else 0
      in
        (
          {model
            | dy = dy1
            , y = y1
            , x = x1
            , dx = dx1
            , dtheta = dtheta1
            , theta = theta1
          }
          , Cmd.none
        )
    KeyDown code ->
      case code of
        37 ->
          ({model | leftThruster = True}, Cmd.none)
        38 ->
          ({model | mainEngine = True}, Cmd.none)
        39 ->
          ({model | rightThruster = True}, Cmd.none)
        _ ->
          (model, Cmd.none)
    KeyUp code ->
      case code of
        37 ->
          ({model | leftThruster = False}, Cmd.none)
        38 ->
          ({model | mainEngine = False}, Cmd.none)
        39 ->
          ({model | rightThruster = False}, Cmd.none)
        82 ->
          init
        _ ->
          (model, Cmd.none)

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Keyboard.downs KeyDown
      , Keyboard.ups KeyUp
      , AnimationFrame.diffs Tick
    ]

-- View

view : Model -> Html Msg
view model =
  let
    divStyle = Html.Attributes.style [("padding", "0px")]
  in
    div [ divStyle ] [ rocketView model ]

rocketView : Model -> Html Msg
rocketView model =
  let
    rocketY = toString (100 - config.vehicle.y - model.y)
    rocketX = toString model.x
    rotatePoint = {
      x = model.x + config.vehicle.x / 2 |> toString
      , y = 100 - model.y - config.vehicle.y / 2 |> toString
      }
    rocketTransform = "rotate("
      ++ toString model.theta
      ++ " "
      ++ rotatePoint.x
      ++ " "
      ++ rotatePoint.y
      ++ ")"
  in
    svg [ viewBox "0 0 200 100", width "100%" ]
      [
        line [ x1 "0", y1 "100", x2 "200", y2 "100", stroke "darkgreen" ] []
        , use [
          xlinkHref "graphics/helicopter.svg#helicopter"
          , x rocketX
          , y rocketY
          , transform (rocketTransform)
          ] []
      ]
-- xlinkHref
-- Init

init : (Model, Cmd Msg)
init =
  (
    {
      mainEngine = False,
      rightThruster = False,
      leftThruster = False,
      x = 100,
      y = config.vehicle.y,
      theta = 0,
      dx = 0,
      dy = 0,
      dtheta = 0
    },
    Cmd.none
  )
