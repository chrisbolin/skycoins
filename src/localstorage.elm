module LocalStorage exposing (get, set, remove, clear)

{-| A library for interacting with localStorage.
# API
@docs get, set, remove, clear
-}

import Native.LocalStorage
import Json.Decode exposing (Value)
import Task exposing (Task)


{-| Set a new element in localStorage with the given key and value.
    set "my-key" (Json.Encode.string "my-val")
-}
set : String -> Value -> Task () ()
set key val =
  Native.LocalStorage.setItem key val


{-| Retrieve an element from localStorage with the given key. It may be empty.
    case get "my-key" of
      Just val -> val
      Nothing -> "Nothing"
-}
get : String -> Maybe String
get key =
  Native.LocalStorage.getItem key


{-| Remove an element from localStorage with the given key.
    remove "my-key"
-}
remove : String -> Task () ()
remove key =
  Native.LocalStorage.removeItem key


{-| Clear all the elements in localStorage.
    clear ()
-}
clear : () -> Task () ()
clear =
  Native.LocalStorage.clear