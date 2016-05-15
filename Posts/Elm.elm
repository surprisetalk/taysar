
module Posts.Elm exposing (post)

import Html exposing (..)
import Html.Attributes exposing (..)

post =
  {
    title = "Elm"
    , image = "http://elm-lang.org/assets/examples/sketch-n-sketch.png"
    , body =
      [ "I've been really digging [Elm](http://elm-lang.org) lately."
      , "In fact, this very website was made using Elm!"
      , "It's a lot of fun."
      ]
  }
