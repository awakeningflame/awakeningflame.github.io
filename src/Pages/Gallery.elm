module Pages.Gallery exposing (..)

import Pages.Gallery.Exhibit as Exhibit
import Links exposing (Links)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)
import Html.App        as Html

import String


type alias Model a =
  { topics : Array
      { topic : String
      , subtopics : Array
          { subtopic : String
          , images : List
              { url : String
              , name : String
              }
          }
      , activeSubtopic : Int
      }
  , activeTopic : Int
  }

type Msg
  = SetActiveTopic Int
  | SetActiveSubTopic Int


init : List { topic : String
            , subtopics : List
                { subtopic : String
                , images : List
                    { url : String
                    , name : String
                    }
                }
            } -> Model
init xs =
  { topics = List.map
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
      }


view : Links a -> Model a -> List (Html a)
view links model =
  let viewTopic mX =
        let viewSubtopic mX =
              case mX of
                Nothing -> []
                Just {subtopic,activeSubtopic,images}
                  [ h3  [ class "ui header"
                        , id <| case String.uncons <| printAppLinks <| AppGallery
                                        <| Just (topic, Just (subtopic, Nothing)) of
                                  Nothing    -> Debug.crash "printing a link isn't a hash"
                                  Just (h,x) ->
                                    if h == '#'
                                    then x
                                    else Debug.crash "printing a link isn't a hash"
                        , onClick <| links.toGallery
                                  <| Just (topic, Just (subtopic, Nothing))
                        ] [text subtopic]
                  , 
                  ]

        in  case mX of
              Nothing -> []
              Just {topic,subtopics,activeSubtopic} ->
                [h2 [class "ui header"] [text topic]]
                ++ viewSubtopic (Array.get activeSubtopic subtopics)

  in  [ div [class "one column row"]
          [ div [class "column"]
              [ div [class "top attached tabular menu"]
                  <| List.map
                       (\(idx, {topic, subtopics}) ->
                           a [ class <| "item"
                                 ++ if idx == model.activeTopic
                                    then " active"
                                    else ""
                             , onClick <| SetActiveTopic idx
                             ] [text topic]
                       )
                  <| Array.toIndexedList model.topics
              , div [class "ui bottom attached segment"
                  <| [ div [class "ui secondary menu"]
                         <| case Array.get model.activeTopic model.topics of
                              Nothing -> Debug.crash "inconsistent array"
                              Just {subtopics,activeSubtopic} ->
                                let go (idx,{subtopic}) ->
                                      a [ class <| "item"
                                            if idx == activeSubtopic
                                            then " active"
                                            else ""
                                        , onClick <| SetActiveSubTopic idx
                                        ] [text subtopic]
                                in  List.map go (Array.toIndexedList subtopics)
                     ] ++ viewTopic (Array.get model.activeTopic model.topics)
              ]
          ]
      ]
