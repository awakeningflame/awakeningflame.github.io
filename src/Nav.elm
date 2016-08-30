module Nav exposing (..)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)

import Links exposing (AppLink (..), Links)


type alias Model =
  { currentPage : AppLink
  }


type Msg
  = ChangePage AppLink


init : AppLink -> Model
init link =
  { currentPage = link
  }


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    ChangePage p -> { model | currentPage = p } ! []


view : Links a -> Model -> Html (Result Msg a)
view links model =
  div [class "ui top fixed inverted menu"]
    [ a [ class <| "violet item"
            ++ case model.currentPage of
                 AppHome -> " active"
                 _       -> ""
        , onClick <| Ok links.toHome
        ]
        [ i [class "icon home"] []
        , text "Home"
        ]
    , a [ class <| "teal item"
            ++ case model.currentPage of
                 AppGallery _ -> " active"
                 _            -> ""
        , onClick <| Ok <| links.toGallery
            { topic = Nothing }
        ]
        [ i [class "icon camera retro"] []
        , text "Gallery"
        ]
    , div [class "right menu"]
        [ a [ class <| "green item"
                ++ case model.currentPage of
                    AppContact -> " active"
                    _          -> ""
            , onClick <| Ok links.toContact
            ]
            [ i [class "icon mail"] []
            , text "Contact"
            ]
        ]
    ]
