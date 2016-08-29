module Pages.NotFound exposing (..)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)


view : String -> List (Html a)
view s =
  [ div [class "one column row"]
      [ div [class "column"]
          [ div [class "ui segment"]
              [ h1 [class "ui header"] [text "404 - Not Found"]
              , p []
                  [ text <| "The page \"" ++ s
                      ++ "\" was not found. Redirecting you to the homepage..."
                  ]
              ]
          ]
      ]
  ]
