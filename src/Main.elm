module Main exposing (..)

import Links exposing (AppLink (..), Links)
import Nav
import Responsive
import Pages.Home     as Home
import Pages.Gallery  as Gallery
import Pages.Contact  as Contact
import Pages.NotFound as NotFound
import Modals.GalleryFocus as GalleryFocus

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
  , modals      : { galleryFocus : GalleryFocus.Model Msg
                  }
  , pages       : { gallery : Gallery.Model Msg
                  }
  }


type Msg
  = ChangePage AppLink -- non-effectful
  | ToPage AppLink     -- effectful
  | ChangeWindowSize {height : Int, width : Int}
  | NavMsg Nav.Msg
  | GalleryFocusMsg (GalleryFocus.Msg Msg)



type alias Flags =
  { gallery : List
      { topic : String
      , subtopics : List
          { subtopic : String
          , images   : List
              { url  : String
              , name : String
              }
          }
      }
  }


init : Flags -> AppLink -> (Model, Cmd Msg)
init flags link =
  { currentPage = link
  , nav         = Nav.init link
  , windowSize  = Responsive.Mobile
  , modals      = { galleryFocus = GalleryFocus.init
                  }
  , pages       = { gallery = { gallery = Gallery.init flags.gallery }
                  }
  } ! [ Links.notFoundRedirect link <| ToPage AppHome
      , Cmd.map ChangeWindowSize <| Task.performLog Window.size
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
              , case p of
                  AppGallery (Just (topic, Just (subtopic, Just name))) ->
                    mkCmd <| GalleryFocusMsg <| GalleryFocus.Focus
              ]
    ChangeWindowSize s ->
      { model | windowSize = Responsive.fromWidth s.width
      } ! []
    NavMsg a ->
      let (nav,eff) = Nav.update a model.nav
      in  { model | nav = nav } ! [Cmd.map NavMsg eff]
    GalleryFocusMsg a ->
      let (g, eff) = GalleryFocus.update a model.modals.galleryFocus
      in  { model | modals = let m = model.modals
                             in  { m | galleryFocus = g
                                 }
          } ! [Cmd.map GalleryFocusMsg eff]


view : Model -> Html Msg
view model =
  div []
    [ Html.map (\r -> case r of
                        Err x -> NavMsg x
                        Ok  x -> x)
        <| Nav.view links model.nav
    , div [ style [ ("padding-top", "4rem")
                  ]
          ] -- pusher
        [ div [ class "ui grid container"
              ]
            <| viewCurrentPage model
        ]
    , GalleryFocus.view model.modals.galleryFocus
    ]


viewCurrentPage : Model -> List (Html Msg)
viewCurrentPage model =
  case model.currentPage of
    AppHome       -> Home.view {windowSize = model.windowSize}
    AppGallery _  -> Gallery.view links
                       [ ("Steampunk Fedora"
                         , [ ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           , ( "images/hat/1.jpg"
                             , ChangePage AppContact
                             )
                           ]
                         )
                       ]
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
  , toGallery = ToPage << AppGallery
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
