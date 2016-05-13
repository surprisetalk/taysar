
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Html.Events exposing (onClick)
import Markdown exposing (toHtml)
import Taysar.Test

main : Program Never
main = 
  Html.beginnerProgram { model = home, view = view, update = update }
      
-- MODEL --

type alias Content = String

type alias Post = { title : String, body : List Content  }

type alias Model = 
  { menu : List Post, content : Post }
    
posts : List Post
posts = 
  [ Taysar.Test.post ]

home : Model
home =
  { menu = posts, content = Taysar.Test.post }

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
  div [] [ nav model.menu, story model.content ]
      
nav_link : Post -> Html Msg
nav_link post = 
  a [ href "#", onClick (ViewPost post) ] [ text post.title ]
      
nav : List Post -> Html Msg
nav posts = 
  div [] ( List.map nav_link posts )
         
story : Post -> Html Msg
story content = 
  div [] 
  [
    h1 [] [ 
        text 
            <| toString content.title 
    ]
  , text 
        <| toString content.body
  ]
  
