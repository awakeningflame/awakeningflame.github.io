module Main exposing (..)

import Links exposing (AppLink (..), Links)
import Nav

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)
import Html.App        as Html
import Navigation

import Cmd.Extra exposing (mkCmd)



type alias Model =
  { currentPage : AppLink
  , nav         : Nav.Model
  }


type Msg
  = ChangePage AppLink -- non-effectful
  | ToPage AppLink     -- effectful
  | NavMsg Nav.Msg


init : AppLink -> (Model, Cmd Msg)
init link =
  { currentPage = link
  , nav         = Nav.init link
  } ! [ Links.notFoundRedirect link <| ToPage AppHome
      ]


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    ChangePage p ->
      { model | currentPage = p
      } ! [mkCmd <| NavMsg <| Nav.ChangePage p]
    ToPage p ->
      model ! [ mkCmd <| ChangePage p
              , Navigation.newUrl <| Links.printAppLinks p
              ]
    NavMsg a ->
      let (nav,eff) = Nav.update a model.nav
      in  { model | nav = nav } ! [Cmd.map NavMsg eff]


view : Model -> Html Msg
view model =
  div []
    [ Html.map (\r -> case r of
                        Err x -> NavMsg x
                        Ok  x -> x)
        <| Nav.view links model.nav
    , div [] -- pusher
        [ div [ class "ui grid container"
              , style [("padding-top", "4rem")]
              ]
            [ viewCurrentPage model
            ]
        ]
    ]


viewCurrentPage : Model -> Html Msg
viewCurrentPage model =
  case model.currentPage of
    AppHome       -> text "home"
    AppGallery    -> text "gallery"
    AppContact    -> text "contact"
    AppNotFound s -> text <| "Page \"" ++ s ++ "\" not found. Redirecting..."


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- Url related

urlParser : Navigation.Parser AppLink
urlParser = Navigation.makeParser (\loc -> Links.parseAppLinks loc.hash)


urlUpdate : AppLink -> Model -> (Model, Cmd Msg)
urlUpdate link model =
  model
  ! [ Links.notFoundRedirect link <| ToPage AppHome
    , mkCmd <| ChangePage link
    ]


links : Links Msg
links =
  { toHome    = ToPage AppHome
  , toGallery = ToPage AppGallery
  , toContact = ToPage AppContact
  }

------


main : Program Never
main = Navigation.program urlParser
         { init          = init
         , update        = update
         , view          = view
         , subscriptions = subscriptions
         , urlUpdate     = urlUpdate
         }
