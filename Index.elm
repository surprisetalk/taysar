
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Html.Events exposing (onClick)
import String exposing (..)
import Markdown exposing (toHtml)
import Style

import Posts.Home
import Posts.Elm
import Posts.Blog
import Posts.BBHH

main : Program Never
main = 
  Html.beginnerProgram { model = home, view = view, update = update }
      
-- MODEL --

type alias Content = String

type alias Post =
  { title : String
  , image : String
  , body : List Content
  }

type alias Model = 
  { menu : List Post
  , content : Post
  }
    
posts : List Post
posts = 
  -- [ Posts.Home.post
  -- , Posts.Elm.post
  [ Posts.Blog.post
  , Posts.BBHH.post
  ]

home : Model
home =
  let
    blank = { title = "", image = "", body = [ "" ] }
    post = List.head posts
  in
    { menu = posts
    , content = Maybe.withDefault blank post
    }

-- UPDATE --
    
update : Msg -> Model -> Model
update msg model = 
    case msg of
        ViewPost post ->
            { model | content = post }

-- VIEW --

type Msg = ViewPost Post

view : Model -> Html Msg
view model =
  div [ style Style.site ]
    [ nav model.menu
    , story model.content
    ]

nav : List Post -> Html Msg
nav posts = 
  let
    header =
      div [ style Style.header ]
        [ img [ style Style.header_img, src "me.png" ] []
        , h1 [ style Style.header_title ]
          [ a
            [ style Style.link
            , href "#"
            , onClick (ViewPost home.content)
            ]
            [ text "TAYSAR"
            ]
          ]
        , p [ style Style.header_subtitle ] [ text "essays and stories" ]
        ]
    link post = 
      li [ style Style.sidebar_link ]
        [ a 
          [ style Style.link
          , href "#"
          , onClick (ViewPost post)
          ]
          [ text post.title
          ]
        ]
    links =
      List.map link posts
  in
    div [ style Style.sidebar ]
      [ header
      , ul [ style Style.sidebar_links ] links
      ]
         
-- TODO: use case statement to parse different *Types* of paragraphs
story : Post -> Html Msg
story content = 
  let
    image = if (String.isEmpty content.image) then [] else [ img [ style Style.story_image, src content.image ] [] ]
    title = h2 [ style Style.story_title ] [ text content.title ]
    body = div [ style Style.story_body ] (List.map (Markdown.toHtml []) content.body)
  in
    div [ style Style.story ] 
      <| image ++ [ body ]
        -- [ title
        -- , body
        -- ]
  
