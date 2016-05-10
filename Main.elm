import Html exposing (Html, button, div, text, hr)
import Html.App as Html
import Html.Events exposing (onClick)
import Markdown exposing (toHtml)

main : Program Never
main =
  Html.beginnerProgram { model = 0, view = view, update = update }


type Msg = Increment | Decrement

update : Msg -> number -> number
update msg model =
  case msg of
    Increment ->
      model + 1

    Decrement ->
      model - 1

view : a -> Html Msg
view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (toString model) ]
    , button [ onClick Increment ] [ text "+" ]
    , hr [] []
    , Markdown.toHtml [] markdown
    ]


markdown : String
markdown = """

# This is a Battleground

[Markdown](http://daringfireball.net/projects/markdown/) lets you
write content in a really natural way.

  * You can have lists, like this one
  * Make things **bold** or *italic*
  * Embed snippets of `code`
  * Create [links](/)
  * ...

The [elm-markdown][] package parses all this content, allowing you
to easily generate blocks of `Element` or `Html`.

[elm-markdown]: http://package.elm-lang.org/packages/evancz/elm-markdown/latest

"""


