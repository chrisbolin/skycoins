module Utils exposing (..)

floatModulo number modulo =
  let
    rounded = round number
    difference = toFloat rounded - number
  in
    if number > modulo then number - modulo
    else if number < 0 then number + modulo
    else number
