module Pages.Home exposing (..)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)

import Responsive


type alias Config =
  { windowSize : Responsive.WindowSize
  }


view : Config -> List (Html a)
view config =
  [ div [class "one column row"]
      [ div [class "column"]
          [ div [class "ui clearing segment"]
              [ logo config
              , img [ class <| "ui rounded left floated image" ++
                               if Responsive.isMobile config.windowSize
                               then " small"
                               else " medium"
                    , src "images/kevin.jpg"
                    ] []
              , h2 [class "ui header"] [text "About Kevin"]
              , p [] [text "I make wire wrap jewelry and accessories as well as blow glass! I love life I love creating I love the earth and I love you!"]
              ]
          ]
      ]
  ]

logo : Config -> Html a
logo config =
  div [ style <|
          if Responsive.isMobile config.windowSize
          then [ ( "background"
                 , "linear-gradient(135deg, #271e3f 0%,#2c3277 52%,#1d005e 52%,#36174f 100%)"
                 )
               , ("padding", "4rem")
               ]
          else [ ( "background"
                 , "url('images/bg.jpg') no-repeat"
                 )
               , ("background-size", "cover")
               , ("padding-top", "12rem")
               , ("padding-bottom", "12rem")
               , ("padding-left", "6rem")
               ]
      , id "logo"
      ]
      [ h1 ( [ class "ui inverted header"
             ] ++ if Responsive.isMobile config.windowSize
                  then []
                  else [style [("text-shadow","0px 0px 5px rgba(34, 0, 57, 1)")]]
           )
          [ text "Awakening Flame Accessories"
          , div [class "sub header"]
              [text "Enhance Your Spirit"]
          ]
      ]
