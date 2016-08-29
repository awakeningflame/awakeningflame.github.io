module Links exposing (..)

import String
import Time
import Cmd.Extra as Task
import Task
import Process
import Http


type alias Either a b = Result a b

type AppLink
  = AppHome
  | AppGallery ( Maybe ( String
                       , Maybe ( String
                               , Maybe String
                               )
                       )
               )
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
                  Nothing -> AppGallery Nothing
                  Just (c,h) ->
                    if c /= '/'
                    then AppNotFound s
                    else
                      let ss = List.map Http.uriDecode <| String.split "/" h
                      in  case ss of
                            (topic :: []) ->
                              AppGallery <| Just (topic, Nothing)
                            (topic :: subtopic :: []) ->
                              AppGallery <| Just (topic, Just (subtopic, Nothing))
                            (topic :: subtopic :: name :: []) ->
                              AppGallery <| Just (topic, Just (subtopic, Just name))
                            _ -> AppNotFound s
                    then AppGallery <| Just <| Left
                      { header = Http.uriDecode h }
                    else if c == '~'
                    then AppGallery <| Just <| Right
                      { focus = Http.uriDecode h }
                    else AppNotFound s
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
          AppGallery mH -> "gallery"
                       ++ case mT of
                            Nothing -> ""
                            Just (topic,mS) ->
                              "/" ++ Http.uriEncode topic
                                ++ case mS of
                                     Nothing -> ""
                                     Just (subtopic,mN) ->
                                       "/" ++ Http.uriEncode subtopic
                                         ++ case mN of
                                              Nothing -> ""
                                              Just name -> Http.uriEncode name
          AppContact    -> "contact"
          AppNotFound _ -> "not-found"
  in  "#" ++ printed


type alias Links a =
  { toHome    : a
  , toGallery : Maybe (String, Maybe (String, Maybe String)) -> a
  , toContact : a
  }


notFoundRedirect : AppLink -> a -> Cmd a
notFoundRedirect link toPage =
  case link of
    AppNotFound _ ->
      Task.performLog <|
        (Process.sleep (3 * Time.second)) `Task.andThen` (\_ -> Task.succeed toPage)
    _ -> Cmd.none
