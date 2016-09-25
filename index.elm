import Html exposing (Html, button, div, text, h1, h3)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing ( style )
import AnimationFrame
import Debug exposing (log)
import Keyboard exposing (KeyCode)

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
    dTheta: Float
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
        intervalLength = intervalLengthMs / 100
        dy1 = model.dy - 1 * intervalLength
          + if model.mainEngine then 10 * intervalLength else 0
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
          h1 [] [ text (toString model.mainEngine)]
          , h1 [] [ text (toString model.leftThruster)]
          , h1 [] [ text (toString model.rightThruster)]
          , h3 [] [ model.y |> round |> toString |> text ]
          , h3 [] [ model.dy |> round |> toString |> text ]
      ]

-- Init

init : (Model, Cmd Msg)
init =
  (
    Model False False False 0 0 0 0 0 0,
    Cmd.none
  )
