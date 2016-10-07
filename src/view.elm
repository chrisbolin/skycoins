module View exposing (view)

import Html exposing (Html, div)
import Html.Attributes exposing (style, type')
import Svg exposing (svg, circle, line, rect, use, g, a, text, text', Attribute)
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
        , opacity
        , xlinkHref
        , stroke
        , fill
        , transform
        , strokeWidth
        , fontFamily
        , fontSize
        , textAnchor
        )
import Model exposing (Model, State(Paused, Flying), Goal(Coin))
import Config exposing (config)
import Msg exposing (Msg(Tick, KeyUp, KeyDown))


constants :
    { fontFamily : Attribute a
    , red : String
    }
constants =
    { fontFamily = fontFamily "VT323, monospace"
    , red = "#dd5555"
    }


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
        , base model
        , score model
        , debris model
        , vehicle model
        , vehicle { model | x = model.x - 200 }
        , title model
        ]


score : Model -> Svg.Svg a
score model =
    let
        score =
            if model.state == Paused && model.score == 0 then
                model.previousScore
            else
                model.score
    in
        g []
            [ text' [ y "13", x "3", constants.fontFamily, fontSize "14" ] [ text (toString score) ]
            , text' [ y "5", x "158", constants.fontFamily, fontSize "4", fill "#ddd" ]
                [ text ("ground speed, knots: " ++ (model.dx |> abs |> round |> toString))
                ]
            ]


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


base : Model -> Svg.Svg a
base model =
    let
        baseY =
            100 - config.base.y

        vehicleWidth =
            config.vehicle.x * cos (degrees model.theta)
    in
        g []
            [ line
                -- ocean
                [ x1 "0"
                , y1 "100"
                , x2 "200"
                , y2 "100"
                , stroke config.base.color
                , strokeWidth (config.base.y * 2 |> toString)
                ]
                []
            , line
                -- pad
                [ x1 "50"
                , y1 (baseY + 0.5 |> toString)
                , x2 (50 + config.pad.x |> toString)
                , y2 (baseY + 0.5 |> toString)
                , stroke config.pad.color
                , strokeWidth (config.pad.y |> toString)
                ]
                []
            , line
                -- shadow
                [ x1 (model.x - vehicleWidth / 2 |> toString)
                , y1 (baseY + 0.5 |> toString)
                , x2 (model.x + vehicleWidth / 2 |> toString)
                , y2 (baseY + 0.5 |> toString)
                , stroke "black"
                , opacity "0.4"
                , strokeWidth "1"
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


title : Model -> Svg.Svg a
title model =
    if model.state == Paused then
        g [ fontSize "7", fill constants.red ]
            [ text' [ y "50", constants.fontFamily, fontSize "59" ] [ text "SKYCOINS" ]
            , text' [ y "62", x "2", constants.fontFamily ]
                [ text """"A really shitty game." - early fan"""
                ]
            , text' [ y "70", x "2.9", constants.fontFamily ]
                [ text "get coins. land safely. repeat."
                ]
            , text' [ y "78", x "2.9", constants.fontFamily ]
                [ text "up/left/right"
                ]
            , text' [ y "88", x "2.9", constants.fontFamily, fill "black" ]
                [ text "PRESS SPACE TO PLAY"
                ]
            , text' [ y "92", x "166", constants.fontFamily, fontSize "4", fill "black" ]
                [ a
                    [ y "50", xlinkHref "http://chris.bolin.co", fill "black" ]
                    [ text "© 2016 chris bolin"
                    ]
                ]
            ]
    else
        text ""
