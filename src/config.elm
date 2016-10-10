module Config exposing (config)


type alias Config =
    { vehicle :
        { x : Float
        , y : Float
        }
    , gravity : Float
    , engine : Float
    , thrusters : Float
    , backgroundColor : String
    , base :
        { y : Float
        , color : String
        }
    , pad :
        { y : Float
        , x : Float
        , color : String
        }
    , correction :
        { theta : Float
        , dx : Float
        }
    , coin :
        { x : Float
        , y : Float
        }
    , debris :
        { x : Float
        , y : Float
        }
    , mobileWidth : Float
    }


config : Config
config =
    { vehicle =
        { x = 28
        , y = 15
        }
    , gravity = 1.2
    , engine = 2.1
    , thrusters = 1
    , backgroundColor = "#9DACC9"
    , base =
        { color = "#202692"
        , y = 10
        }
    , pad =
        { color = "#808080"
        , x = 30
        , y = 3
        }
    , correction =
        { theta = 2
        , dx = 1.1
        }
    , coin =
        { x = 4
        , y = 9
        }
    , debris =
        { x = 40
        , y = 20
        }
    , mobileWidth = 75
    }
