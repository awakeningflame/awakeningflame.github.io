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
import Dict exposing (Dict)

import Cmd.Extra as Task exposing (mkCmd)



type alias GalleryTrie =
  Dict String ( Int
              , Dict String ( Int
                            , Dict String (Dict String { url : String})
                            )
              )



type alias Model =
  { currentPage : AppLink
  , nav         : Nav.Model
  , windowSize  : Responsive.WindowSize
  , height      : Int
  , modals      : { galleryFocus : GalleryFocus.Model Msg
                  }
  , pages       : { gallery : Gallery.Model
                  , galleryTrie : GalleryTrie
                  }
  }


type Msg
  = ChangePage AppLink -- non-effectful
  | ToPage AppLink     -- effectful
  | ChangeWindowSize {height : Int, width : Int}
  | NavMsg Nav.Msg
  | GalleryFocusMsg (GalleryFocus.Msg Msg)
  | CloseGalleryFocus AppLink
  | GalleryMsg      Gallery.Msg



type alias Flags =
  { gallery : List
      { topic : String
      , subtopics : List Gallery.Subtopic
      }
  }


init : Flags -> AppLink -> (Model, Cmd Msg)
init flags link =
  { currentPage = link
  , nav         = Nav.init link
  , windowSize  = Responsive.Mobile
  , height      = 0
  , modals      = { galleryFocus = GalleryFocus.init
                  }
  , pages       = { gallery = Gallery.init flags.gallery
                  , galleryTrie =
                      Dict.fromList <|
                        List.indexedMap (\tI t ->
                          ( t.topic
                          , ( tI
                            , Dict.fromList <|
                                List.indexedMap (\sI s ->
                                  ( s.subtopic
                                  , ( sI
                                    , Dict.fromList <|
                                      List.map (\i ->
                                        ( i.item
                                        , Dict.fromList <|
                                            List.map (\x -> (x.name, { url = x.url }))
                                              i.images
                                        )
                                        )
                                        s.items
                                    )
                                  )
                                  )
                                  t.subtopics
                            )
                          )
                          ) flags.gallery
                  }
  } ! [ Links.notFoundRedirect link <| ToPage AppHome
      , Cmd.map ChangeWindowSize <| Task.performLog Window.size
      , mkCmd <| ChangePage link
      ]


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    ChangePage p ->
      { model | currentPage = p
      } ! [ mkCmd <| NavMsg <| Nav.ChangePage p
          , let failPage = mkCmd <| ToPage <| AppNotFound <| Links.printAppLinks p
                handleTopic (topic, {subtopic}) =
                  case Dict.get topic model.pages.galleryTrie of
                    Nothing -> failPage
                    Just (tI,s) ->
                      Cmd.batch
                        [ mkCmd <| GalleryMsg <| Gallery.SetActiveTopic tI
                        , case subtopic of
                            Nothing -> Cmd.none
                            Just sub -> handleSubtopic topic s sub
                        ]
                handleSubtopic topic s (subtopic, { item }) =
                  case Dict.get subtopic s of
                    Nothing -> failPage
                    Just (sI,i) ->
                      Cmd.batch
                        [ mkCmd <| GalleryMsg <| Gallery.SetActiveSubTopic sI
                        , case item of
                            Nothing -> Cmd.none
                            Just ite -> handleItem topic subtopic i ite
                        ]
                handleItem topic subtopic i (item, { image }) =
                  case Dict.get item i of
                    Nothing -> failPage
                    Just x ->
                      case image of
                        Nothing -> Cmd.none
                        Just name -> handleImage topic subtopic item x name
                handleImage topic subtopic item x name =
                  case Dict.get name x of
                    Nothing -> failPage
                    Just {url} ->
                      mkCmd <| GalleryFocusMsg <| GalleryFocus.Focus
                        { url = url
                        , name = name
                        , onUnFocus = CloseGalleryFocus <|
                            AppGallery
                              { topic = Just (topic,
                              { subtopic = Just (subtopic,
                              { item = Just (item,
                              { image = Nothing })})})}
                        }
            in  case p of
                  AppGallery { topic } ->
                    case topic of
                      Nothing -> Cmd.none
                      Just top -> handleTopic top
                  _ -> Cmd.none
          ]
    ToPage p ->
      model ! [ mkCmd <| ChangePage p
              , Navigation.newUrl <| Links.printAppLinks p
              ]
    ChangeWindowSize s ->
      { model | windowSize = Responsive.fromWidth s.width
              , height     = s.height
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
    CloseGalleryFocus l ->
      model ! [ mkCmd <| GalleryFocusMsg <| GalleryFocus.UnFocus
              , mkCmd <| ToPage l
              ]
    GalleryMsg a ->
      let (g,eff) = Gallery.update a model.pages.gallery
      in  { model | pages = let p = model.pages
                            in  { p | gallery = g }
          } ! [Cmd.map GalleryMsg eff]


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
        [ div ( [ class "ui grid container"
                ] ++ if Responsive.isMobile model.windowSize
                     then [style [("margin","0 !important")]]
                     else []
              )
            <| viewCurrentPage model
        ]
    , div ( [ class <| "ui dimmer modals page transition"
                ++ case model.modals.galleryFocus.focus of
                     Nothing -> " hidden"
                     Just _  -> " visible active"
            ] ++ case model.modals.galleryFocus.focus of
                   Nothing -> []
                   Just {onUnFocus} ->
                     [ onClick onUnFocus
                     ]
          )
        [ GalleryFocus.view { height = model.height } model.modals.galleryFocus
        ]
    ]


viewCurrentPage : Model -> List (Html Msg)
viewCurrentPage model =
  case model.currentPage of
    AppHome       -> Home.view {windowSize = model.windowSize}
    AppGallery _  -> List.map (Html.map (\r -> case r of
                                          Err x -> GalleryMsg x
                                          Ok  x -> x))
                       <| Gallery.view links model.pages.gallery
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


main : Program Flags
main = Navigation.programWithFlags urlParser
         { init          = init
         , update        = update
         , view          = view
         , subscriptions = subscriptions
         , urlUpdate     = urlUpdate
         }
