module Utils exposing (..)

-- inefficient but effective for our purposes


floatModulo : Float -> Float -> Float
floatModulo number modulo =
    if number > modulo then
        floatModulo (number - modulo) modulo
    else if number < 0 then
        floatModulo (number + modulo) modulo
    else
        number
