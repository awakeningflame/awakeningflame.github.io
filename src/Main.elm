module Main exposing (..)

import Links exposing (AppLink (..), Links)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)
import Html.App        as Html
import Navigation



type alias Model =
  { currentPage : AppLink
  }


type Msg
  = ChangePage AppLink


init : AppLink -> (Model, Cmd Msg)
init link =
  { currentPage = link
  } ! [ Links.notFoundRedirect link <| ChangePage AppHome
      ]


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    ChangePage p ->
      { model | currentPage = p
      } ! []


view : Model -> Html Msg
view model =
  case model.currentPage of
    AppHome       -> text "home"
    AppNotFound s -> text <| "Page \"" ++ s ++ "\" not found"


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- Url related

urlParser : Navigation.Parser AppLink
urlParser = Navigation.makeParser (\loc -> Links.parseAppLinks loc.hash)


urlUpdate : AppLink -> Model -> (Model, Cmd Msg)
urlUpdate link model =
  { model | currentPage = link
  } ! [ Links.notFoundRedirect link <| ChangePage AppHome
      ]


links : Links Msg
links =
  { toHome = ChangePage AppHome
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
