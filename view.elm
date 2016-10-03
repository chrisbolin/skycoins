module View exposing (view)

import Html exposing (Html, button, div, h6)
import Html.Attributes exposing (style, type')
import Svg exposing (svg, circle, line, rect, use, g, text, text')
import Svg.Attributes
    exposing
        ( viewBox
        , width
        , x
        , y
        , x1
        , y1
        , x2
        , y2
        , xlinkHref
        , stroke
        , transform
        , strokeWidth
        , fontFamily
        )
import Model exposing (Model, State(Paused, Flying), Goal(Coin))
import Config exposing (config)
import Msg exposing (Msg(Tick, KeyUp, KeyDown))


view : Model -> Html Msg
view model =
    let
        mainStyle =
            Html.Attributes.style
                [ ( "padding", "0px" )
                , ( "height", "100vh" )
                , ( "background-color", config.base.color )
                ]

        fontImport =
            Html.node "style"
                [ type' "text/css" ]
                [ Html.text "@import 'https://fonts.googleapis.com/css?family=VT323"
                ]
    in
        div [ mainStyle ]
            [ fontImport
            , game model
            ]


game : Model -> Html Msg
game model =
    svg
        [ viewBox "0 0 200 100"
        , width "100%"
        , Svg.Attributes.style ("background-color:" ++ config.backgroundColor)
        ]
        [ coin model
        , base
        , score model
        , debris model
        , vehicle model
        , vehicle { model | x = model.x - 200 }
        ]


score : Model -> Svg.Svg a
score model =
    text' [ y "10", fontFamily "VT323, monospace" ] [ text (toString model.score) ]


coin : Model -> Svg.Svg a
coin model =
    if model.goal == Coin then
        use
            [ xlinkHref ("graphics/coin.svg#coin")
            , x (model.coin.x - config.coin.x / 2 |> toString)
            , y (100 - model.coin.y - config.coin.y / 2 |> toString)
            ]
            []
    else
        text ""


base : Svg.Svg a
base =
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


debris : Model -> Svg.Svg a
debris model =
    if model.debris.show then
        use
            [ xlinkHref ("graphics/debris.svg#debris")
            , x (model.debris.x - config.debris.x / 2 |> toString)
            , y (100 - model.debris.y - config.debris.y / 2 |> toString)
            ]
            []
    else
        text ""


vehicle : Model -> Svg.Svg a
vehicle model =
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
