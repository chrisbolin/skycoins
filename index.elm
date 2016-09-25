import Html exposing (Html, button, div, text, h6)
import Html.App as App
import Html.Attributes exposing ( style )
import AnimationFrame
import Debug exposing (log)
import Keyboard exposing (KeyCode)
import Svg exposing (svg, circle, line, rect)
import Svg.Attributes exposing (..)

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
          (if model.y > 0 then model.dy - 1 * intervalLength else 0)
          + (if model.mainEngine then 3 * intervalLength else 0)
        -- derived
        y1 = model.y + dy1 * intervalLength
      in
        (
          {model
            | dy = dy1
            , y = y1
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
    rocketY = (90 - model.y) |> toString
  in
    svg [ viewBox "0 0 100 100", width "500px" ]
      [
        rect [ x "45", y rocketY, width "10", height "10" ] []
        , line [ x1 "0", y1 "100", x2 "100", y2 "100", stroke "darkgreen" ] []
      ]

-- Init

init : (Model, Cmd Msg)
init =
  (
    {
      mainEngine = False,
      rightThruster = False,
      leftThruster = False,
      x = 0,
      y = 110,
      theta = 0,
      dx = 0,
      dy = 0,
      dtheta = 0
    },
    Cmd.none
  )
