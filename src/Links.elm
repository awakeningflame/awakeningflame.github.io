module Links exposing (..)

import String
import Time
import Cmd.Extra as Task
import Task
import Process
import Http



type alias GallerySub =
  { topic : Maybe
      ( String
      , { subtopic : Maybe
            ( String
            ,   { item : Maybe
                    ( String
                    , { image : Maybe String
                      }
                    )
                }
            )
        }
      )
  }


type AppLink
  = AppHome
  | AppGallery GallerySub
  | AppContact
  | AppNotFound String


-- Parses the _fragment_ / hash component of a URI
parseAppLinks : String -> AppLink
parseAppLinks s =
  let parse : String -> AppLink
      parse s' =
        if s' == "home"
        then AppHome
        else if String.startsWith "gallery" s'
        then let s'' = String.dropLeft 7 s'
             in case String.uncons s'' of
                  Nothing -> AppGallery { topic = Nothing }
                  Just (c,h) ->
                    if c /= '/'
                    then AppNotFound s
                    else
                      let ss = List.map Http.uriDecode <| String.split "/" h
                      in  case ss of
                            (topic :: []) ->
                              AppGallery
                                { topic = Just (topic, { subtopic = Nothing })
                                }
                            (topic :: subtopic :: []) ->
                              AppGallery
                                { topic = Just (topic,
                                    { subtopic = Just (subtopic, { item = Nothing })
                                    }
                                )}
                            (topic :: subtopic :: item :: []) ->
                              AppGallery
                                { topic = Just (topic,
                                    { subtopic = Just (subtopic,
                                        { item = Just (item, { image = Nothing })
                                        }
                                    )}
                                )}
                            (topic :: subtopic :: item :: image :: []) ->
                              AppGallery
                                { topic = Just (topic,
                                    { subtopic = Just (subtopic,
                                        { item = Just (item,
                                            { image = Just image
                                            }
                                        )}
                                    )}
                                )}
                            _ -> AppNotFound s
        else if s' == "contact"
        then AppContact
        else AppNotFound s'

  in  case String.uncons s of
        Nothing -> AppHome
        Just (h,xs) ->
          if h /= '#'
          then AppNotFound s
          else parse xs


printAppLinks : AppLink -> String
printAppLinks l =
  let printed =
        case l of
          AppHome       -> "home"
          AppGallery mT -> "gallery"
            ++ case mT.topic of
                 Nothing -> ""
                 Just (topic,mS) ->
                   "/" ++ Http.uriEncode topic
                     ++ case mS.subtopic of
                          Nothing -> ""
                          Just (subtopic,mI) ->
                            "/" ++ Http.uriEncode subtopic
                              ++ case mI.item of
                                   Nothing -> ""
                                   Just (item,mN) ->
                                     "/" ++ Http.uriEncode item
                                       ++ case mN.image of
                                            Nothing -> ""
                                            Just image ->
                                              "/" ++ Http.uriEncode image
          AppContact    -> "contact"
          AppNotFound _ -> "not-found"
  in  "#" ++ printed


type alias Links a =
  { toHome    : a
  , toGallery : GallerySub -> a
  , toContact : a
  }


notFoundRedirect : AppLink -> a -> Cmd a
notFoundRedirect link toPage =
  case link of
    AppNotFound _ ->
      Task.performLog <|
        (Process.sleep (3 * Time.second)) `Task.andThen` (\_ -> Task.succeed toPage)
    _ -> Cmd.none
