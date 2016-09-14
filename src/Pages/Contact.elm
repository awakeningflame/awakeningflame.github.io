module Pages.Contact exposing (..)

import Html            exposing (..)
import Html.Attributes exposing (..)
-- import Html.Events     exposing (..)


view : List (Html a)
view =
  [ div [class "one column row"]
      [ div [class "column"]
          [ div [class "ui segment"]
              [ h1 [class "ui dividing header"] [text "Contact"]
              , div [class "ui stackable grid"]
                  [ div [class "row"]
                      [ div [class "eight wide column"]
                          [ p [] [ text """
You're more than welcome to ♫ call me on my celll phooone ♫ , but in case I don't answer,
feel free to leave a voicemail, or drop me a line on my email.
"""
                                 ]
                          ]
                      , div [class "eight wide column"]
                          [ div [class "ui list"]
                              [ a [ class "ui item"
                                  , href "tel:1-303-909-5347"
                                  ]
                                  [ i [class "phone icon"] []
                                  , div [class "content"]
                                      [ div [class "header"] [text "+1 (303) 909 - 5347"]
                                      , div [class "description"] [text "cell"]
                                      ]
                                  ]
                              , a [ class "ui item"
                                  , href "mailto:kevinpeterman29@gmail.com"
                                  ]
                                  [ i [class "mail icon"] []
                                  , div [class "content"]
                                      [ div [class "header"] [text "kevinpeterman29@gmail.com"]
                                      , div [class "description"] [text "email"]
                                      ]
                                  ]
                              ]
                          ]
                      ]
                  ]
              ]
          ]
      ]
  ]
