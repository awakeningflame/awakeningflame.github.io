module Pages.Home exposing (..)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)


view : List (Html a)
view =
  [ div [class "one column row"]
      [ div [class "column"]
          [ logo
          , img [ class "ui medium rounded left floated image"
                , src "images/kevin.jpg"
                ] []
          , h2 [class "ui header"] [text "About Kevin"]
          , p [] [text "Kevin's a badass slayer-pimp with fuckin' dope shit constantly CONSTANTLY GODDAMNIT"]
          , p [] [text "I make wire wrap jewelry and accessories as well as blow glass! I love life I love creating I love the earth and I love you!"]
          ]
      ]
  ]

logo : Html a
logo =
  div [ style [ ("background","url('images/bg.jpg')")
              , ("padding", "4rem")
              ]
      ]
      [ h1 [class "ui inverted header"]
          [ text "Awakening Flame Accessories"
          , div [class "sub header"]
              [text "Enkindle Your Spirit"]
          ]
      ]
