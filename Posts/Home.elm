
module Posts.Home exposing (post)

import Html exposing (..)
import Html.Attributes exposing (..)
-- import Html.Lazy exposing (lazy)

-- TODO: use Html.Lazy ?
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
    title = "Hello"
    , image = "http://ellenpronk.com/wp-content/uploads/2015/06/bjork.jpg"
    , body =
    [ "Let there be sadness."
    ]
  }
