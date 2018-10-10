
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
import Json.Decode as D exposing (Decoder)

import Dict exposing (Dict)

import Http exposing (..)

import Markdown as MD


---- HELPERS -------------------------------------------------------------------

tuple a b = ( a, b )


---- MODEL ---------------------------------------------------------------------

type WebResult x
  = Loading
  | Failure Http.Error
  | Success x

type alias Path
  = String
  
type alias Name
  = String

type alias Link
  = String

type alias Category
  = { name : Name
    , path : Path
    }

type alias Content
  = { name : Name
    , path : Path
    , link : Link
    }

type Page
  = NotFound
  | Index
  | Contents Path (Result Http.Error (Dict Path Content))
  | Markdown Path String

type alias Model
  = { key        : Nav.Key
    , categories : Result Http.Error (Dict Path Category)
    , page       : WebResult Page
    }


---- INIT ----------------------------------------------------------------------

init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
  let ( page, cmd ) = goTo url
  in  ( { key        = key
        , categories = Ok Dict.empty
        , page       = page
        }
      , Cmd.batch
        [ cmd
        , Http.send LoadGithubCategories
          <| Http.get "https://api.github.com/repos/surprisetalk/writings/contents" githubIndexDecoder
        ]
      )

githubIndexDecoder : Decoder (Dict Path Category)
githubIndexDecoder
  = D.map Dict.fromList
    <| D.map (List.filterMap identity)
    <| D.list
    <| D.map3
       (\ typ name path ->
          case typ of
            "dir" -> Just (path, Category name path)
            _     -> Nothing
       )
       ( D.field "type" D.string )
       ( D.field "name" D.string )
       ( D.field "path" D.string )

---- MSG -----------------------------------------------------------------------

type Msg
  = NoOp
  | GoTo Url
  | ClickedLink UrlRequest
  | LoadGithubCategories    (Result Http.Error (Dict Path Category))
  | LoadGithubCategory Path (Result Http.Error (Dict Path Content ))
  | LoadGithubContent  Path (Result Http.Error            String   )



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

      LoadGithubCategory categoryPath contents ->
        ( { model | page = Success (Contents categoryPath contents)
          }
        , Cmd.none
        )

      LoadGithubContent categoryPath httpResponse ->
        ( { model
            | page
              = case httpResponse of
                  Err error   -> Failure error
                  Ok  body    -> Success (Markdown categoryPath body)
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
      Just [ categoryPath ] ->
        ( Loading
        , Http.send (LoadGithubCategory categoryPath)
          <| Http.get
             ( crossOrigin "https://api.github.com"
               [ "repos", "surprisetalk", "writings", "contents", categoryPath ]
               []
             )
             githubCategoryDecoder
        )
      Just [ categoryPath, contentPath ] ->
        ( Loading      
        , Http.send (LoadGithubContent categoryPath)
          <| Http.getString
             ( crossOrigin "https://raw.githubusercontent.com"
               [ "surprisetalk", "writings", "master", categoryPath, contentPath ]
               []
             )
        )
      _ ->
        ( Success NotFound
        , Cmd.none
        )

githubCategoryDecoder : Decoder (Dict Path Content)
githubCategoryDecoder
  = D.map Dict.fromList
    <| D.map (List.filterMap identity)
    <| D.list
    <| D.map4
       (\ typ name path link ->
          case typ of
            "file" -> Just (path, Content name path link)
            _      -> Nothing
       )
       ( D.field "type"                   D.string )
       ( D.field "name"                   D.string )
       ( D.field "path"                   D.string )
       ( D.field "download_url" downloadUrlDecoder )

downloadUrlDecoder : Decoder String
downloadUrlDecoder
  = let parseDownloadUrl
          = UrlP.parse
         <| UrlP.map (\categoryPath contentPath -> absolute [ categoryPath, contentPath ] [])
         <| downloadUrlParser
        downloadUrlParser
          = UrlP.s "surprisetalk"
          </> UrlP.s "writings"
          </> UrlP.s "master"
          </> UrlP.string
          </> UrlP.string
     in D.andThen
        (\ downloadUrl ->
           case Maybe.andThen parseDownloadUrl (Url.fromString downloadUrl) of
             Just url -> D.succeed url
             Nothing  -> D.fail ("Couldn't parse '" ++ downloadUrl ++ "' into a URL.")
        )
     <| D.string


---- SUBSCRIPTIONS -------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model
  = Sub.none


---- VIEW ----------------------------------------------------------------------

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

view : Model -> Document Msg
view model
  = { title = "TAYSAR"
    , body  = -- [ viewTaysar model
              -- ]
              [ fontAwesomeCDN
              , css
              , viewTaysar model
              ]
    }

viewHeader
  = Html.header []
    [ h1 []
      [ a [ href "/" ]
        [ text "TAYSAR"
        ]
      ]
    ]

viewAside model
  = aside []
    [ case model.categories of
        Err e ->
          p []
          [ text (httpErrorToString e)
          ]
        Ok categories ->
          nav []
          [ ul []
            <| List.map
               (\ {name,path} ->
                  li []
                  [ a [ href (absolute [ path ] [])
                      ]
                    [ text name
                    ]
                  ]
               )
            <| Dict.values
            <| categories
          ]
    ]

viewSection model
  = section []
    [ case model.page of
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
            Contents category contentsResult ->
              case contentsResult of
                Err error ->
                  text (httpErrorToString error)
                Ok contents ->
                  ul []
                  <| List.map (\{name,path,link} -> li [] [ a [ href link ] [ text name ] ])
                  <| Dict.values
                  <| contents
            Markdown _ content ->
              lazy (MD.toHtml []) content
    ]
            

viewTaysar : Model -> Html Msg
viewTaysar model
  = main_ []
    [ viewHeader
    , viewAside model
    , viewSection model
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
