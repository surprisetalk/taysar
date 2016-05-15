
module Posts.Blog exposing (post)

import Html exposing (..)
import Html.Attributes exposing (..)

post =
  {
    title = "On Lifeless Blogs"
    , image = "github_taysar.png"
    , body = [ body ]
  }

body = """

# On Lifeless Blogs
      
Today's blogs are [dead fish]() -- stale snapshots of the past.

## Dynamic
  
News should be version-controlled.
Data and opinions change; articles should too.
     
Wikipedia "grows".

## Interactive

## Collaborative

"""
