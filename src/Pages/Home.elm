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
          [ div [class "ui segment"]
              [ logo config
              , img [ class "ui medium rounded left floated image"
                    , src "images/kevin.jpg"
                    ] []
              , h2 [class "ui header"] [text "About Kevin"]
              , p [] [text "Kevin's a badass slayer-pimp with fuckin' dope shit constantly CONSTANTLY GODDAMNIT"]
              , p [] [text "I make wire wrap jewelry and accessories as well as blow glass! I love life I love creating I love the earth and I love you!"]
              ]
          ]
      ]
  ]

logo : Config -> Html a
logo config =
  div [ style [ ( "background"
                , if Responsive.isMobile config.windowSize
                  then "linear-gradient(135deg, #271e3f 0%,#2c3277 52%,#1d005e 52%,#36174f 100%)"
                  else "linear-gradient(to right, rgba(39,30,63,0.5) 0%,rgba(109,40,99,0.2) 50%,rgba(0,0,0,0) 100%), url('images/bg.jpg') no-repeat"
                )
              , ("padding", "4rem")
              ]
      , id "logo"
      ]
      [ h1 [class "ui inverted header"]
          [ text "Awakening Flame Accessories"
          , div [class "sub header"]
              [text "Enhance Your Spirit"]
          ]
      ]
