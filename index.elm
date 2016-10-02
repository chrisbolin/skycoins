module Main exposing (..)

import Html exposing (Html, button, div, text, h6)
import Html.App as App
import Html.Attributes exposing (style)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Svg exposing (svg, circle, line, rect, use)
import Svg.Attributes exposing (viewBox, width, x, y, x1, y1, x2, y2, xlinkHref, stroke, transform)
import Model exposing (Model)
import Config exposing (config)


-- Main


main : Program Never
main =
    App.program
        { subscriptions = subscriptions
        , view = view
        , update = update
        , init = init
        }



-- Update


type Msg
    = KeyDown KeyCode
    | KeyUp KeyCode
    | Tick Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick intervalLengthMs ->
            ( Model.tick { model | intervalLengthMs = intervalLengthMs }, Cmd.none )

        KeyDown code ->
            case code of
                32 ->
                    -- Spacebar
                    ( { model | paused = not model.paused }, Cmd.none )

                37 ->
                    -- Left
                    ( { model | leftThruster = True, paused = False }, Cmd.none )

                38 ->
                    -- Up
                    ( { model | mainEngine = True, paused = False }, Cmd.none )

                39 ->
                    -- Right
                    ( { model | rightThruster = True, paused = False }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        KeyUp code ->
            case code of
                37 ->
                    ( { model | leftThruster = False }, Cmd.none )

                38 ->
                    ( { model | mainEngine = False }, Cmd.none )

                39 ->
                    ( { model | rightThruster = False }, Cmd.none )

                82 ->
                    init

                _ ->
                    ( model, Cmd.none )



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
        divStyle =
            Html.Attributes.style [ ( "padding", "0px" ) ]
    in
        div [ divStyle ]
            [ gameView model, text (toString model.score) ]


gameView : Model -> Html Msg
gameView model =
    svg [ viewBox "0 0 200 100", width "100%" ]
        [ line [ x1 "0", y1 "100", x2 "200", y2 "100", stroke "darkgreen" ] []
        , coinView model
        , vehicleView model
        , vehicleView { model | x = model.x - 200 }
        ]


coinView : Model -> Svg.Svg a
coinView model =
    use
        [ xlinkHref ("graphics/coin.svg#coin")
        , x (model.coin.x - config.coin.x / 2 |> toString)
        , y (100 - model.coin.y - config.coin.y / 2 |> toString)
        ]
        []


vehicleView : Model -> Svg.Svg a
vehicleView model =
    let
        rotateY =
            100 - model.y |> toString

        leftX =
            model.x - config.vehicle.x / 2 |> toString

        topY =
            100 - model.y - config.vehicle.y / 2 |> toString

        vehicleTransform =
            "rotate(" ++ toString model.theta ++ " " ++ toString model.x ++ " " ++ rotateY ++ ")"

        svgId =
            if model.paused then
                "none"
            else if model.mainEngine && (model.rightThruster || model.leftThruster) then
                "all"
            else if model.mainEngine then
                "main"
            else if model.rightThruster || model.leftThruster then
                "turn"
            else
                "none"
    in
        use
            [ xlinkHref ("graphics/helicopter.svg#" ++ svgId)
            , x leftX
            , y topY
            , transform (vehicleTransform)
            ]
            []



-- Init


init : ( Model, Cmd Msg )
init =
    ( { paused = True
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
      }
    , Cmd.none
    )
