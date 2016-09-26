import Html exposing (Html, button, div, text, h6)
import Html.App as App
import Html.Attributes exposing ( style )
import AnimationFrame
import Debug exposing (log)
import Keyboard exposing (KeyCode)
import Svg exposing (svg, circle, line, rect, use)
import Svg.Attributes exposing (..)

rocket = {x = 5, y = 2}

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
        -- computed
        dy1 =
          (if model.y > 0 then model.dy - 1 * intervalLength else 0) -- gravity (and floor)
          + (if model.mainEngine then 3 * intervalLength * cos (degrees model.theta) else 0) -- engine
        dx1 =
          model.dx
          + (if model.mainEngine then 3 * intervalLength * sin (degrees model.theta) else 0) -- engine
        dtheta1 =
          ( if model.leftThruster == model.rightThruster then model.dtheta
            else if model.leftThruster then model.dtheta - 1 * intervalLength
            else if model.rightThruster then model.dtheta + 1 * intervalLength
            else model.dtheta
            )
        -- derived
        x1 = model.x + dx1 * intervalLength
        y1 = model.y + dy1 * intervalLength
        theta1 = model.theta + dtheta1 * intervalLength
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
    divStyle = Html.Attributes.style [("padding", "10px")]
  in
    div [ divStyle ]
      [
          rocketView model
          , h6 [] [ model.y |> round |> toString |> text ]
          , h6 [] [ model.dy |> round |> toString |> text ]
          , h6 [] [ text (toString model.mainEngine)]
          , h6 [] [ text (toString model.leftThruster)]
          , h6 [] [ text (toString model.rightThruster)]
      ]

rocketView : Model -> Html Msg
rocketView model =
  let
    rocketY = toString (100 - rocket.y - model.y)
    rocketX = toString model.x
    rotatePoint = {
      x = model.x + rocket.x / 2 |> toString
      , y = 100 - model.y - rocket.y / 2 |> toString
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
        , Svg.text' [
          x rocketX
          , y rocketY
          , transform (rocketTransform)
          ] [text "🚁"]
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
      x = 45,
      y = 110,
      theta = 0,
      dx = 0,
      dy = 0,
      dtheta = 0
    },
    Cmd.none
  )
