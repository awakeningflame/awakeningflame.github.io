module Modals.GalleryFocus where

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


view : Model a -> Html (Result (Msg a) a)
view model =
  div [ class <| "ui modal"
          case model.focus of
            Nothing -> " hidden"
            Just _  -> " visible active"
      ]
    <| case model.focus of
         Nothing -> []
         Just {url,name,onUnFocus} ->
            [ div [class "header"] [text name]
            , div [class "image content"]
                [ img [src url, class "image"] []
                ]
            , div [class "actions"]
                [ button [ class "ui button"
                         , onClick <| Ok onUnFocus
                         ]
                    [ i [class "icon close"] []
                    , text "Close"
                    ]
                ]
            ]
