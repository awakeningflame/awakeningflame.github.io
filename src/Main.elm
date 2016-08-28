module Main exposing (..)

import Links exposing (AppLink (..), Links)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)
import Html.App        as Html
import Navigation

import Cmd.Extra exposing (mkCmd)



type alias Model =
  { currentPage : AppLink
  }


type Msg
  = ChangePage AppLink -- non-effectful
  | ToPage AppLink     -- effectful


init : AppLink -> (Model, Cmd Msg)
init link =
  { currentPage = link
  } ! [ Links.notFoundRedirect link <| ToPage AppHome
      ]


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    ChangePage p ->
      { model | currentPage = p
      } ! []
    ToPage p ->
      model ! [ mkCmd <| ChangePage p
              , Navigation.newUrl <| Links.printAppLinks p
              ]


view : Model -> Html Msg
view model =
  div []
    [ case model.currentPage of
        AppHome       -> text "home"
        AppNotFound s -> text <| "Page \"" ++ s ++ "\" not found. Redirecting..."
    ]


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
  { toHome = ToPage AppHome
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
