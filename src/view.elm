module View exposing (view)

import Html exposing (Html, div, h1, input)
import Html.Attributes exposing (style, type', class, placeholder, maxlength, value)
import Html.Events exposing (onInput, onClick)
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
import Model exposing (Model, LeaderboardEntry, State(Paused, Flying), View(Leaderboard, AddToLeaderboard), Goal(Coin))
import Config exposing (config)
import Msg exposing (Msg(Tick, KeyUp, KeyDown, ChangeName, SubmitName))


constants :
    { font : String
    , red : String
    }
constants =
    { font = "VT323, monospace"
    , red = "#dd5555"
    }


view : Model -> Html Msg
view model =
    let
        mainStyle =
            style
                [ ( "padding", "0px" )
                , ( "height", "100vh" )
                , ( "background-color", config.base.color )
                , ( "font-family", "VT323, monospace" )
                ]
    in
        div [ mainStyle ]
            [ game model
            , leaderboard model
            ]


game : Model -> Html Msg
game model =
    svg
        [ viewBox "0 0 200 100"
        , width "100%"
        , Svg.Attributes.style ("background-color:" ++ config.backgroundColor)
        , fontFamily constants.font
        ]
        [ coin model
        , base model
        , score model
        , debris model
        , vehicle model
        , dashboard model
        , vehicle { model | x = model.x - 200 }
        , paused model
        ]


score : Model -> Svg.Svg a
score model =
    text' [ y "11", x "3", fontSize "11" ] [ text (toString model.score) ]


dashboard : Model -> Svg.Svg a
dashboard model =
    if model.dashboard == True then
        g [ fontSize "4", fill "#ddd", transform "translate(165 8)" ]
            [ text' []
                [ text ("Ground Speed: " ++ (model.dx |> abs |> round |> toString))
                ]
            , text' [ y "5" ]
                [ text ("Altitude: " ++ (model.y - 12 |> round |> toString))
                ]
            ]
    else
        text ""


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


paused : Model -> Svg.Svg a
paused model =
    if model.state == Paused then
        g []
            [ title
              -- personal best
            , text' [ y "11", x "100", fontSize "11", fill "black", textAnchor "middle" ]
                [ text
                    (if model.highScore > 0 then
                        ("Best " ++ toString model.highScore)
                     else
                        ""
                    )
                ]
            , menu
            , text' [ y "99", x "166", fontSize "4", fill "black" ]
                [ a
                    [ xlinkHref "http://chris.bolin.co", fill "white" ]
                    [ text "© 2016 chris bolin"
                    ]
                ]
            ]
    else
        text ""


title : Svg.Svg a
title =
    g [ fontSize "7", fill constants.red ]
        [ text' [ y "50", fontSize "59" ] [ text "SKYCOINS" ]
        , text' [ y "62", x "2" ]
            [ text """"I hate this." - an early fan"""
            ]
        , text' [ y "70", x "2.9" ]
            [ text "get coins. land safely. repeat."
            ]
        , text' [ y "78", x "2.9" ]
            [ text "up/left/right"
            ]
          -- press start
        , text' [ y "88", x "100", fill "white", textAnchor "middle" ]
            [ text "PRESS SPACE"
            ]
        ]


menu : Svg.Svg a
menu =
    g [ fontSize "4", fill "white", transform "translate(165 60)" ]
        [ text' [] [ text "[L] - Leaderboard" ]
        , text' [ y "5" ] [ text "[D] - Dashboard" ]
        , text' [ y "10" ] [ text "[Space] - Pause" ]
        ]


leaderboardRow : LeaderboardEntry -> Html Msg
leaderboardRow entry =
    div [ class "row" ]
        [ div [] [ text entry.username ]
        , div [ class "score" ] [ entry.score |> toString |> text ]
        ]


leaderboard : Model -> Html Msg
leaderboard model =
    if (model.view == Leaderboard) || (model.view == AddToLeaderboard) then
        div []
            [ div [ class "leaderboard" ]
                (div [ class "header row" ] [ text "leaderboard" ]
                    :: List.map
                        leaderboardRow
                        model.leaderboard
                )
            , addToLeaderboard model
            ]
    else
        div [] []


addToLeaderboard : Model -> Html Msg
addToLeaderboard model =
    if model.view == AddToLeaderboard then
        div [ class "add-to-leaderboard leaderboard" ]
            [ div [ class "header row" ] [ text "new high score!" ]
            , div [ class "row" ]
                [ div [] [ input [ value model.username, placeholder "you", maxlength 3, onInput ChangeName ] [] ]
                , div [ class "score" ] [ model.newHighScore |> toString |> text ]
                ]
            , div [ class "button", onClick SubmitName ] [ text "OK" ]
            ]
    else
        div [] []
