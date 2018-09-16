
module Taysar exposing (..)


---- IMPORTS -------------------------------------------------------------------

import Browser exposing (..)
import Browser.Navigation as Nav exposing (..)

import Url exposing (..)
import Url.Builder as UrlB exposing (..)
import Url.Parser  as UrlP exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (..)

import Json.Encode as E
import Json.Decode as D

import Http exposing (..)

import Markdown as MD


---- HELPERS -------------------------------------------------------------------

tuple a b = ( a, b )


---- MODEL ---------------------------------------------------------------------

type WebResult x
  = Loading
  | Failure Http.Error
  | Success x

type Page
  = NotFound
  | Index
  | Category (Result Http.Error (List (String, String)))
  | Markdown String

type alias Model =
  { key        : Nav.Key
  , categories : Result Http.Error (List String)
  , page       : WebResult Page
  }


---- INIT ----------------------------------------------------------------------

init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
  let ( page, cmd ) = goTo url
  in  ( { key        = key
        , categories = Ok []
        , page       = page
        }
      , Cmd.batch
        [ cmd
        , Http.send LoadGithubCategories
          <| Http.get "https://api.github.com/repos/surprisetalk/essays/contents" githubIndexDecoder
        ]
      )

githubIndexDecoder
  = D.map (List.filterMap identity)
    <| D.list
    <| D.map2
       (\ name typ ->
          case typ of
            "dir" -> Just name
            _     -> Nothing
       )
       ( D.field "name" D.string )
       ( D.field "type" D.string )

---- MSG -----------------------------------------------------------------------

type Msg
  = NoOp
  | GoTo Url
  | ClickedLink UrlRequest
  | LoadGithubCategories (Result Http.Error (List         String ))
  | LoadGithubContent    (Result Http.Error               String  )
  | LoadGithubCategory   (Result Http.Error (List (String,String)))



---- UPDATE --------------------------------------------------------------------

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model
  = case msg of

      NoOp ->
        ( model
        , Cmd.none
        )

      LoadGithubCategories categories ->
        ( { model | categories = categories
          }
        , Cmd.none
        )

      GoTo url ->
        let ( page, cmd ) = goTo url
        in  ( { model
                | page
                  = case page of
                      Loading -> model.page
                      _       -> page
              }
            , cmd
            )

      ClickedLink urlRequest ->
        case urlRequest of
          Internal url ->
            ( model
            , Nav.pushUrl model.key (Url.toString url)
            )
          External url ->
            ( model
            , Nav.load url
            )

      LoadGithubCategory category ->
        ( { model | page = Success (Category category)
          }
        , Cmd.none
        )

      LoadGithubContent httpResponse ->
        ( { model
            | page
              = case httpResponse of
                  Err error   -> Failure error
                  Ok  content -> Success (Markdown content)
          }
        , Cmd.none
        )

goTo : Url -> ( WebResult Page, Cmd Msg )
goTo url
  = let parser
          = UrlP.oneOf
            [ UrlP.map          [   ]  (UrlP.top)
            , UrlP.map          [   ]  (UrlP.s "index")
            , UrlP.map          [   ]  (UrlP.s "index.html")
            , UrlP.map (\c ->   [c  ]) (UrlP.string)
            , UrlP.map (\c p -> [c,p]) (UrlP.string </> UrlP.string)
            ]
    in case UrlP.parse parser url of
      Just [] ->
        ( Success Index
        , Cmd.none
        )
      Just [ cat ] ->
        ( Loading
        , Http.send LoadGithubCategory
          <| Http.get
             ( crossOrigin "https://api.github.com"
               [ "repos", "surprisetalk", "essays", "contents", cat ]
               []
             )
             githubCategoryDecoder
        )
      Just [ cat, pagelet ] ->
        ( Loading      
        , Http.send LoadGithubContent
          <| Http.getString
             ( crossOrigin "https://raw.githubusercontent.com"
               [ "surprisetalk", "essays", "master", cat, pagelet ]
               []
             )
        )
      _ ->
        ( Success NotFound
        , Cmd.none
        )

githubCategoryDecoder
  = D.map (List.filterMap identity)
    <| D.list
    <| D.map3
       (\ name path typ ->
          case typ of
            "file" -> Just (name, path)
            _      -> Nothing
       )
       ( D.field "name" D.string )
       ( D.field "path" D.string )
       ( D.field "type" D.string )


---- SUBSCRIPTIONS -------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model
  = Sub.none


---- VIEW ----------------------------------------------------------------------

view : Model -> Document Msg
view model
  = { title = "TAYSAR"
    , body  = [ fontAwesomeCDN
              , css
              , taysar model
              ]
    }

fontAwesomeCDN
  = node "link"
    [ rel "stylesheet"
    , href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"
    ]
    []

css
  = node "link"
    [ rel "stylesheet"
    , href "/sakura.css"
    ]
    []

taysar : Model -> Html Msg
taysar model
  = main_ []
    [ h1 []
      [ a [ href "/" ]
        [ text "TAYSAR"
        ]
      ]
    , case model.categories of
        Err e ->
          p []
          [ text (httpErrorToString e)
          ]
        Ok categories ->
          ul []
          <| List.map
             (\ c ->
                li []
                [ a [ href (absolute [ c ] [])
                    ]
                  [ text c
                  ]
                ]
             )
             categories
    , case model.page of
        Loading ->
          text "loading..."
        Failure error -> 
          text (httpErrorToString error)
        Success page ->
          case page of
            NotFound ->
              text "not found"
            Index ->
              text "home"
            Category rpaths ->
              case rpaths of
                Err error ->
                  text (httpErrorToString error)
                Ok paths ->
                  ul []
                  <| List.map (\(name,path) -> li [] [ a [ href path ] [ text (String.replace "_" " " (stripFileExtension name)) ] ])
                     paths
            Markdown content ->
              lazy (MD.toHtml []) content
            
    ]

stripFileExtension
  = String.split "."
    >> List.reverse
    >> List.drop 1
    >> List.reverse
    >> String.join "."

httpErrorToString error
  = case error of
      BadUrl        body    -> body
      Timeout               -> "timeout"
      NetworkError          -> "network error"
      BadStatus    {body}   -> body
      BadPayload    body  _ -> body


---- PROGRAM -------------------------------------------------------------------

main : Program () Model Msg
main
  = application
    { init          = init
    , view          = view
    , update        = update
    , subscriptions = subscriptions
    , onUrlRequest  = ClickedLink
    , onUrlChange   = GoTo
    }
