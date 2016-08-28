module Main exposing (..)

import Links exposing (AppLink (..), Links)
import Nav
import Responsive
import Pages.Home     as Home
import Pages.Gallery  as Gallery
import Pages.Contact  as Contact
import Pages.NotFound as NotFound

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)
import Html.App        as Html
import Navigation
import Window

import Cmd.Extra as Task exposing (mkCmd)



type alias Model =
  { currentPage : AppLink
  , nav         : Nav.Model
  , windowSize  : Responsive.WindowSize
  }


type Msg
  = ChangePage AppLink -- non-effectful
  | ToPage AppLink     -- effectful
  | ChangeWindowSize {height : Int, width : Int}
  | NavMsg Nav.Msg


init : AppLink -> (Model, Cmd Msg)
init link =
  { currentPage = link
  , nav         = Nav.init link
  , windowSize  = Responsive.Mobile
  } ! [ Links.notFoundRedirect link <| ToPage AppHome
      , Cmd.map ChangeWindowSize <| Task.performLog Window.size
      ]


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    ChangePage p ->
      { model | currentPage = p
      } ! [mkCmd <| NavMsg <| Nav.ChangePage p]
    ChangeWindowSize s ->
      { model | windowSize = Responsive.fromWidth s.width
      } ! []
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
    , div [ style [ ("padding-top", "4.5rem")
                  ]
          ] -- pusher
        [ div [ class "ui grid container"
              , style [ ("background","rgba(255,255,255,0.8)")
                      , ("border-radius","0.5rem")
                      ]
              ]
            <| viewCurrentPage model
        ]
    ]


viewCurrentPage : Model -> List (Html Msg)
viewCurrentPage model =
  case model.currentPage of
    AppHome       -> Home.view {windowSize = model.windowSize}
    AppGallery    -> Gallery.view
    AppContact    -> Contact.view
    AppNotFound s -> NotFound.view s


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Window.resizes ChangeWindowSize
    ]


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
