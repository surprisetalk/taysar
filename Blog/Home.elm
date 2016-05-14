
module Blog.Home exposing (post)

import Html exposing (..)
import Html.Attributes exposing (..)

-- post =
--     { 
--       title = "Welcome" 
--     , body =
--         div []
--         [ 
--           p [] [ text "i am" ]
--         , p [] [ text "the one" ]
--         , p [] [ text "who knocks" ]
--         ] 
--     }

post =
  {
    title = "Welcome"
    , body =
    [
      "i am"
    , "the one"
    , "who knocks"
    ]
  }
