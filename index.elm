import Html exposing (Html, button, div, text, h6)
import Html.App as App
import Html.Attributes exposing (style)
import AnimationFrame
import Debug exposing (log)
import Keyboard exposing (KeyCode)
import Svg exposing (svg, circle, line, rect, use)
import Svg.Attributes exposing (viewBox, width, x, y, x1, y1, x2, y2, xlinkHref, stroke, transform)

import Model
import Config exposing (config)

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
      (Model.tick model intervalLengthMs, Cmd.none)
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
