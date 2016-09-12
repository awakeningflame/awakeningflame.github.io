module Pages.Gallery.Exhibit exposing (..)

import Html            exposing (..)
import Html.Attributes exposing (..)
import Html.Events     exposing (..)

import Links exposing (Links)


type alias Images = List {url : String, name : String}



view : Links a
    -> { topic    : String
       , subtopic : String
       , item     : String
       }
    -> Images
    -> Html a
view links {topic,subtopic,item} xs =
  let viewItem {url,name} =
        img [ src url
            , style [("display", "inline-block"),("cursor","pointer")]
            , class "ui small rounded image"
            , onClick <| links.toGallery
                { topic = Just (topic,
                    { subtopic = Just (subtopic,
                        { item = Just (item,
                            { image = Just name
                            })
                        })
                    })
                }
            ] []
            -- TODO: Make continuous thingy
  in  div [ style [ ("text-align", "center")
                  , ("white-space", "nowrap")
                  , ("overflow-x", "auto")
                  ]
          ]
        <| List.map viewItem xs
