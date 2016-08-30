module Pages.Gallery exposing (..)

import Pages.Gallery.Exhibit as Exhibit
import Links exposing (Links, AppLink (..))

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)
import Html.App        as Html

import Array exposing (Array)
import String


type alias Model =
  { topics : Array Topic
  , activeTopic : Int
  }

type Msg
  = SetActiveTopic Int
  | SetActiveSubTopic Int


type alias Topic =
  { topic : String
  , subtopics : Array Subtopic
  , activeSubtopic : Int
  }

type alias Subtopic =
  { subtopic : String
  , items    : List { item   : String
                    , images : Exhibit.Images
                    }
  }


init : List { topic     : String
            , subtopics : List Subtopic
            }
    -> Model
init xs =
  { topics = Array.map
               (\x -> { topic = x.topic
                      , subtopics = Array.fromList x.subtopics
                      , activeSubtopic = 0
                      }
               )
          <| Array.fromList xs
  , activeTopic = 0
  }


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    SetActiveTopic t ->
      { model | activeTopic = t } ! []
    SetActiveSubTopic st ->
      { model | topics =
          Array.indexedMap
            (\idx t ->
               if idx == model.activeTopic
               then { t | activeSubtopic = st }
               else t
            ) model.topics
      } ! []


mkId : AppLink -> String
mkId l =
  case String.uncons <| Links.printAppLinks l of
    Nothing    -> Debug.crash "printing a link isn't a hash"
    Just (h,x) ->
      if h == '#'
      then x
      else Debug.crash "printing a link isn't a hash"


viewSubtopic : Links a
            -> { topic : String }
            -> Maybe Subtopic
            -> List (Html a)
viewSubtopic links {topic} mX =
  case mX of
    Nothing -> []
    Just {subtopic,items} ->
      List.concat (List.map (\{item,images} ->
        [ h2 [ class "ui header"
             , id <| mkId <| AppGallery
                 { topic = Just (topic,
                     { subtopic = Just (subtopic,
                         { item = Just (item, { image = Nothing }) })
                     })
                 }
             , onClick <| links.toGallery
                 { topic = Just (topic,
                     { subtopic = Just (subtopic,
                         { item = Just (item, { image = Nothing }) })
                     })
                 }
             ] [text item]
        , Exhibit.view links
            { topic = topic
            , subtopic = subtopic
            , item = item
            } images
        , div [class "ui divider"] []
        ]) items)


viewTopic : Links a
         -> Maybe Topic
         -> List (Html a)
viewTopic links mX =
  case mX of
    Nothing -> []
    Just {topic,subtopics,activeSubtopic} ->
      viewSubtopic links {topic = topic} (Array.get activeSubtopic subtopics)


view : Links a -> Model -> List (Html (Result Msg a))
view links model =
  [ div [class "one column row"]
      [ div [class "column"]
          [ div [class "ui top attached tabular menu"]
              <| List.map
                   (\ (idx, {topic, subtopics}) ->
                       a [ class <| "item"
                             ++ if idx == model.activeTopic
                                then " active"
                                else ""
                         , onClick <| Err <| SetActiveTopic idx
                         , style <|
                             if idx == model.activeTopic
                             then []
                             else [("color","#fff")]
                         ] [text topic]
                   )
              <| Array.toIndexedList model.topics
          , div [ class "ui bottom attached segment"
                ]
              <| [ div [class "ui secondary pointing menu"]
                     <| case Array.get model.activeTopic model.topics of
                          Nothing -> Debug.crash "inconsistent array"
                          Just {subtopics,activeSubtopic} ->
                            let go (idx,{subtopic}) =
                                  a [ class <| "item"
                                        ++  if idx == activeSubtopic
                                            then " active"
                                            else ""
                                    , onClick <| Err <| SetActiveSubTopic idx
                                    ] [text subtopic]
                            in  List.map go (Array.toIndexedList subtopics)
                 ] ++ ( List.map (Html.map Ok)
                     <| viewTopic links (Array.get model.activeTopic model.topics)
                      )
          ]
      ]
  ]
