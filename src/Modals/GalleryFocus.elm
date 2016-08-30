module Modals.GalleryFocus exposing (..)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)


type alias Model a =
  { focus : Maybe { url : String
                  , name : String
                  , onUnFocus : a
                  }
  }

type Msg a
  = Focus
      { url  : String
      , name : String
      , onUnFocus : a
      }
  | UnFocus


init : Model a
init =
  { focus = Nothing
  }


update : Msg a -> Model a -> (Model a, Cmd (Msg a))
update action model =
  case action of
    Focus f ->
      { model | focus = Just f } ! []
    UnFocus ->
      { model | focus = Nothing } ! []


view : {height : Int} -> Model a -> Html a
view {height} model =
  div [ class <| "ui scrolling fullscreen basic modal"
          ++  case model.focus of
                Nothing -> " hidden"
                Just _  -> " visible active"
      ]
    <| case model.focus of
         Nothing -> []
         Just {url,name,onUnFocus} ->
            [ i [ class "icon close"
                , onClick onUnFocus
                , style [("color", "#fff")]
                ] []
            , div [class "header"] [text name]
            , div [ class "image content"
                  ]
                [ img [ src url
                      , class "ui centered image"
                      , style [("max-height", toString (height - 150) ++ "px")]
                      ] []
                ]
            ]
