module Main exposing (..)

import Html exposing (Html, button, div, text, h6)
import Html.App as App
import Html.Attributes exposing (style)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Svg exposing (svg, circle, line, rect, use, g)
import Svg.Attributes exposing (viewBox, width, x, y, x1, y1, x2, y2, xlinkHref, stroke, transform, strokeWidth)
import Model exposing (Model, State(Paused, Flying))
import Config exposing (config)
import Msg exposing (Msg(Tick, KeyUp, KeyDown))


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick intervalLengthMs ->
            ( Model.interate { model | intervalLengthMs = intervalLengthMs }, Cmd.none )

        KeyDown code ->
            case code of
                32 ->
                    -- Spacebar
                    ( { model
                        | state =
                            if model.state == Paused then
                                Flying
                            else
                                Paused
                      }
                    , Cmd.none
                    )

                37 ->
                    -- Left
                    ( { model | leftThruster = True, state = Flying }, Cmd.none )

                38 ->
                    -- Up
                    ( { model | mainEngine = True, state = Flying }, Cmd.none )

                39 ->
                    -- Right
                    ( { model | rightThruster = True, state = Flying }, Cmd.none )

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
        [ coinView model
        , baseView
        , debrisView model
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


baseView : Svg.Svg a
baseView =
    g []
        [ line
            [ x1 "0"
            , y1 "100"
            , x2 "200"
            , y2 "100"
            , stroke config.base.color
            , strokeWidth (config.base.y * 2 |> toString)
            ]
            []
        , line
            [ x1 "50"
            , y1 (100 - config.base.y |> toString)
            , x2 (50 + config.pad.x |> toString)
            , y2 (100 - config.base.y |> toString)
            , stroke config.pad.color
            , strokeWidth (config.pad.y |> toString)
            ]
            []
        ]


debrisView : Model -> Svg.Svg a
debrisView model =
    if model.debris.show then
        use
            [ xlinkHref ("graphics/debris.svg#debris")
            , x (model.debris.x - config.debris.x / 2 |> toString)
            , y (100 - model.debris.y - config.debris.y / 2 |> toString)
            ]
            []
    else
        Svg.text ""


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
            if model.state == Paused then
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
            , transform vehicleTransform
            ]
            []



-- Init


init : ( Model, Cmd Msg )
init =
    ( Model.initialModel, Cmd.none )
