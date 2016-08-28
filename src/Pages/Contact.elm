module Pages.Contact exposing (..)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)


view : List (Html a)
view =
  [ div [class "one column row"]
      [ div [class "column"]
          [ h1 [class "ui header"] [text "Contact"]
          ]
      ]
  ]
