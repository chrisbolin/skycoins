module View exposing (view)

import Html exposing (Html, div, img, span)
import Html.Attributes exposing (style, type', name, content, src, id)
import Svg exposing (svg, circle, line, rect, use, g, a, text, text', Attribute)
import Svg.Attributes
    exposing
        ( viewBox
        , width
        , height
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
        , cx
        , cy
        , r
        )
import Model exposing (Model, State(Paused, Flying), Goal(..), viewportMaxY)
import Config exposing (config)
import Msg exposing (Msg(..))
import TouchEvents exposing (onTouchStart,onTouchEnd,TouchEvent(..))
import String
import Utils exposing (style')


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
                , ( "-moz-user-select", "none" )
                , ( "-webkit-user-select", "none" )
                , ( "-ms-user-select", "none" )
                , ( "user-select", "none" )
                , ( "-o-user-select", "none" )
                ]

        fontImport =
            Html.node "style"
                [ type' "text/css" ]
                [ Html.text "@import 'https://fonts.googleapis.com/css?family=VT323"
                ]
    in
        div [ mainStyle ]
            [ fontImport
            , Html.node "meta" [ name "viewport", content "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" ] []
            , game model
            , miniVehicle model
            , controls model
            ]


game : Model -> Html Msg
game model =
    svg
        [ viewBox "0 0 200 100"
        , width "100%"
        , height <| toString ( if model.tapped then 105 else 100 ) ++ "vh"
        , style' <| gameStyles model
        , onTouchEnd StartGame
        ]
        <|
            [ coin model
            , base model
            , debris model
            , vehicle model
            , vehicle { model | x = model.x - 200 }
            , title model
            ]

gameStyles model =
    [ ( "background-color", config.backgroundColor ) ]

controls : Model -> Html Msg
controls model =
    if model.tapped && model.state /= Paused then
        div [ onTouchStart TouchOn, onTouchEnd TouchOff, style
                [ ( "position", "fixed" )
                , ( "background", "rgba(100,0,0,0.1)" )
                , ( "width", "100%" )
                , ( "height", "100%" )
                , ( "top", "0%")
                , ( "left", "0%" )
                ]
            ]
            
            [
            ]
        --[ g [ onTouchStart EngineOn, onTouchEnd EngineOff ]
        --    [ circle [ cy "20", cx "20", r "17", fill "#33ff00"] []
        --    , text' [ y "24.5", constants.fontFamily, x "14", fontSize "16", fill "white" ] [ text "UP" ] 
        --    ]
        --, g [ onTouchStart LeftThrustOn, onTouchEnd LeftThrustOff ]
        --    [ circle [ cy "20", cx "150", r "11", fill "white" ] []
        --    , text' [ y "24.5", constants.fontFamily, x "145.5", fontSize "16", fill "black" ] [ text "<" ]
        --    ]
        --, g [ onTouchStart RightThrustOn, onTouchEnd RightThrustOff ]
        --    [ circle [ cy "20", cx "180", r "11", fill "white"] []
        --    , text' [ y "24.5", constants.fontFamily, x "178", fontSize "16", fill "black" ] [ text ">" ]
        --    ]
    else
        div [ style [("display","none")] ] []


hud : Model -> List (Svg.Svg a)
hud model =
    let
        score =
            if model.state == Paused && model.score == 0 then
                model.previousScore
            else
                model.score
        topY = model.y - config.vehicle.y |> round |> toString
    in if model.state /= Paused then
        [ text' [ y <| toString <| viewportMaxY model, x "3", constants.fontFamily, fontSize "12", fill "white" ] [ text <| "SCORE: " ++ toString score ]
        , text' [ y <| toString <| (viewportMaxY model) - 5, x "146.25", constants.fontFamily, fontSize "4", fill "white" ]
            [ text <| "altitude: " ++ topY ++ " | knots: " ++ (model.dx |> abs |> round |> toString)
            ]
        , text' [ y <| toString <| viewportMaxY model, x "154.5", constants.fontFamily, fontSize "4.5", fill "white" ]
            [ text <| "HIGH SCORE: " ++ toString model.highScore ++ " | " ++ toString model.window.width
            ]
        ]
    else
        []


coin : Model -> Svg.Svg a
coin model =
    if model.goal == Coin then
        use
            [ xlinkHref ("/graphics/coin.svg#coin")
            , x (model.coin.x - config.coin.x / 2 |> toString)
            , y ((viewportMaxY model) - model.coin.y - config.coin.y / 2 |> toString)
            ]
            []
    else
        text ""


base : Model -> Svg.Svg Msg
base model =
    let
        maxY = viewportMaxY model
        baseY = maxY - config.base.y
        vehicleWidth = config.vehicle.x * cos (degrees model.theta)
    in
        g [] <|
            [ line
                -- ocean
                [ x1 "0"
                , y1 <| toString maxY
                , x2 "200"
                , y2 <| toString maxY
                , stroke config.base.color
                , strokeWidth (config.base.y * 2 |> toString)
                ] []
            , line
                -- pad
                [ x1 <| toString config.pad.x
                , y1 (baseY + 0.5 |> toString)
                , x2 (config.pad.x + config.pad.width |> toString)
                , y2 (baseY + 0.5 |> toString)
                , stroke <| if model.goal == Pad then config.pad.colorLand else config.pad.color
                , strokeWidth (config.pad.y |> toString)
                ] []
            , line
                -- shadow
                [ x1 (model.x - vehicleWidth / 2 |> toString)
                , y1 (baseY + 0.5 |> toString)
                , x2 (model.x + vehicleWidth / 2 |> toString)
                , y2 (baseY + 0.5 |> toString)
                , stroke "black"
                , opacity "0.4"
                , strokeWidth "1"
                ] []
            ] ++ (hud model)


debris : Model -> Svg.Svg a
debris model =
    if model.debris.show then
        use
            [ xlinkHref ("/graphics/debris.svg#debris")
            , x (model.debris.x - config.debris.x / 2 |> toString)
            , y ((viewportMaxY model) - model.debris.y - config.debris.y / 2 |> toString)
            ]
            []
    else
        text ""


vehicle : Model -> Svg.Svg a
vehicle model =
    let
        maxY = viewportMaxY model

        rotateY =
            maxY - model.y |> toString

        leftX =
            model.x - config.vehicle.x / 2 |> toString

        topY = 
            maxY - model.y - config.vehicle.y / 2 |> toString

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
            [ xlinkHref ("/graphics/helicopter.svg#" ++ svgId)
            , x leftX
            , y topY
            , transform vehicleTransform
            ]
            []

miniVehicle : Model -> Html a
miniVehicle model =
    let
        vehicleTransform = "rotate(" ++ toString model.theta ++ "deg)"
    in
        if model.state /= Paused then
            img
                [ src "graphics/helicopter_white.svg"
                , style <|
                    [ ( "position", "absolute" )
                    , ( "bottom", "5%" )
                    , ( "right", "30%" )
                    , ( "width", "7%" )
                    , ( "transform", vehicleTransform )
                    , ( "-webkit-transform", vehicleTransform )
                    , ( "-moz-transform", vehicleTransform )
                    , ( "-ms-transform", vehicleTransform )
                    , ( "-o-transform", vehicleTransform )
                    ]
                ]
                []
        else
            span [] []


title : Model -> Svg.Svg Msg
title model =
    if model.state == Paused then
        g [ fontSize "7", fill constants.red ]
            [ text' [ y "50", constants.fontFamily, fontSize "59" ] [ text "SKYCOINS" ]
            , text' [ y "62", x "2", constants.fontFamily ]
                [ text "Get coin. Land safely. Repeat."
                ]
            , text' [ y "70", x "2.9", constants.fontFamily ]
                [ text "Use on-screen buttons or up/left/right" 
                ]
            , text' [ y "83", x "25", constants.fontFamily, fill "yellow", fontSize "10" ]
                [ text "TAP ANYWHERE OR PRESS SPACE TO PLAY"
                ]
            , text' [ y "4", x "166", constants.fontFamily, fontSize "4", fill "black" ]
                [ a
                    [ y "50", xlinkHref "http://chris.bolin.co", fill "black" ]
                    [ text "© 2016 chris bolin"
                    ]
                ]
            ]
    else
        text ""
