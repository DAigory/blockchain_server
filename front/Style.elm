module Style exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

headerContainerStyle : Attribute a
headerContainerStyle =
    style [ ("margin-bottom", "40px")
            , ("font-size", "20px")
            , ("position", "relative")
            , ("padding", "30px 0")
            , ("color", "#cdbfe3")
            , ("text-align", "center")
            , ("text-shadow", "0 1px 0 rgba(0,0,0,.1)")
            , ("background-color", "#6f5499")
            , ("background-image", "linear-gradient(to bottom,#563d7c 0,#6f5499 100%)")
            ]

headerWhiteStyle : Attribute a
headerWhiteStyle =
    style [ ("margin-top", "0")
          , ("color", "#fff")
          ]

fullStyle : Attribute a
fullStyle =
    style [ ("width","100%")
          , ("height","100%")
          , ("background-color", "rgba(0,0,0,0.7)")
          , ("position", "fixed")
          , ("top", "0px")
          ]

addContainerStyle : Attribute a
addContainerStyle =
    style [ ("background-color", "#fff")
          , ("margin-top","70px")
          , ("border-radius", "4px 4px 0 0")
          , ("padding", "15px 15px 15px")
          ]
