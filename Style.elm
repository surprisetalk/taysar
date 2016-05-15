
module Style exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

-- STYLE --

(=>) = (,)

type alias Style = List (String, String)

site : Style
site =
  [ "max-width" => "950px"
  , "height" => "100%"
  , "margin" => "0 auto"
  , "font-size" => "1.5em"
  ]
  ++ font

-- TODO: get Noto Sans and Noto Serif
font : Style
font =
  [ "color" => "rgb(42, 42, 42)"
  , "font-size" => "1.5em"
  ]
  ++ sans

sans : Style
sans =
  [ "font-family" => "'Noto Sans', futura, sans-serif" ]
       
serif : Style
serif =
  [ "font-family" => "georgia, serif" ]

link : Style
link =
  [ "text-decoration" => "none"
  , "color" => "#29AB87"
  ]

sidebar : Style
sidebar =
  [ "float" => "left"
  , "box-sizing" => "border-box"
  , "height" => "80%"
  , "width" => "33%"
  , "margin" => "50px 0"
  -- , "border-left" => "1px dotted #CCC"
  , "text-align" => "center"
  -- , "background-color" => "#EEE"
  ]

header : Style
header =
  [ "margin" => "0 0 25px"
  ]

header_title : Style
header_title =
  [ "margin" => "0"
  , "font-size" => "1.5em"
  ]

header_subtitle : Style
header_subtitle =
  [ "margin" => "0"
  , "font-size" => "0.75em"
  , "color" => "#BBB"
  ]

header_img : Style
header_img =
  [ "width" => "50%"
  , "margin" => "10px 0"
  ]

sidebar_links : Style
sidebar_links =
  [ "width" => "75%"
  , "margin" => "15px auto"
  , "padding" => "15px 35px"
  , "text-align" => "left"
  , "list-style" => "none"
  ]

sidebar_link : Style
sidebar_link =
  [ "font-size" => "12pt"
  , "line-height" => "2"
  ]

story : Style
story =
  [ "width" => "66%"
  , "box-sizing" => "border-box"
  , "margin" => "25px 0"
  , "padding" => "50px"
  , "float" => "left"
  -- , "padding" => "0 0 0 50px"
  ]

story_image : Style
story_image =
  [ "width" => "100%"
  , "text-align" => "center"
  ]

story_title : Style
story_title =
  -- [ "text-align" => "center"
  [ "color" => "#444"
  ]
  ++ sans

story_body : Style
story_body =
  [ "font-size" => "12pt"
  , "color" => "#666"
  ]
  ++ serif
