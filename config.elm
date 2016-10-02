module Config exposing (config)


type alias Config =
    { vehicle :
        { x : Float
        , y : Float
        }
    , gravity : Float
    , engine : Float
    , thrusters : Float
    , correction :
        { theta : Float
        , dx : Float
        }
    , coin :
        { x : Float
        , y : Float
        }
    }


config : Config
config =
    { vehicle =
        { x = 25
        , y = 15
        }
    , gravity = 1.5
    , engine = 2.2
    , thrusters = 2
    , correction =
        { theta = 2
        , dx = 1.1
        }
    , coin =
        { x = 4
        , y = 9
        }
    }
