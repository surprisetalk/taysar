
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Html.Events exposing (onClick)
import Markdown exposing (toHtml)
import Blog.Home

main : Program Never
main = 
  Html.beginnerProgram { model = home, view = view, update = update }
      
-- MODEL --

type alias Content = String

type alias Post = { title : String, body : List Content }

type alias Model = 
  { menu : List Post, content : Post }
    
posts : List Post
posts = 
  [ Blog.Home.post ]

home : Model
home =
  { menu = posts, content = Blog.Home.post }

-- UPDATE --
    
update : Msg -> Model -> Model
update msg model = 
    case msg of
        ViewPost post ->
            { model | content = post }

-- VIEW --

type Msg = ViewPost Post

(=>) = (,)

site : List (String, String)
site =
    [ "height" => "100%"
    , "font-size" => "1.5em"
    ]

font : List (String, String)
font =
    [ "font-family" => "futura, sans-serif"
    , "color" => "rgb(42, 42, 42)"
    , "font-size" => "1.5em"
    ]

view : Model -> Html Msg
view model =
  div [ style (site ++ font) ] [ nav model.menu, story model.content ]
      
nav_link : Post -> Html Msg
nav_link post = 
  a [ href "#", onClick (ViewPost post) ] [ text post.title ]
      
sidebar : List (String, String)
sidebar =
    [ "float" => "left"
    , "background-color" => "#DDD"
    , "height" => "100%"
    , "width" => "250px"
    ]

nav : List Post -> Html Msg
nav posts = 
  div [ style sidebar ] ( List.map nav_link posts )
         
story : Post -> Html Msg
story content = 
  div [ style [ "width" => "250px", "float" => "left" ] ] 
    [ h1 []
      [ text content.title 
      ]
    , div [] (List.map (Markdown.toHtml []) content.body)
    ]
  
