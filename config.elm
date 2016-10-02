module Config exposing (config)


type alias Config =
    { vehicle :
        { x : Float
        , y : Float
        }
    , gravity : Float
    , engine :
        Float
        -- up
    , thrusters :
        Float
        -- left/right
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
    , engine =
        2.2
        -- up
    , thrusters =
        2
        -- left/right
    , correction =
        { theta = 2
        , dx = 1.1
        }
    , coin =
        { x = 4
        , y = 9
        }
    }
