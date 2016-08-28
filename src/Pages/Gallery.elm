module Pages.Gallery exposing (..)

import Pages.Gallery.Exhibit as Exhibit
import Links exposing (Links)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)
import Html.App        as Html

import String


view : Links a -> List (String, List (String, a)) -> List (Html a)
view links xs =
  let viewExhibit (n,e) =
        [ let h = String.concat
               <| List.intersperse "-"
               <| String.words
               <| String.toLower n
          in  h2 [ class "ui header"
                 , id <| "gallery:" ++ h
                 , onClick <| links.toGallery <| Just h
                 ] [text n]
        , Exhibit.view e
        , div [class "ui divider"] []
        ]
  in  [ div [class "one column row"]
          [ div [class "column"]
              <| [h1 [class "ui dividing header"] [text "Gallery"]]
              ++ List.concat (List.map viewExhibit xs)
          ]
      ]
