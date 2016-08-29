module Pages.Gallery.Exhibit exposing (..)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)



view : List (String, a) -> Html a
view urls =
  let viewItem (url,toView) =
        img [ src url
            , style [("display", "inline-block")]
            , class "ui small rounded image"
            , onClick toView
            ] []
  in  div [ style [ ("text-align", "center")
                  , ("white-space", "nowrap")
                  ]
          ]
        <| List.map viewItem urls
