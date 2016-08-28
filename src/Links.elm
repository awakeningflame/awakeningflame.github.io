module Links exposing (..)

import String
import Time
import Cmd.Extra as Task
import Task
import Process


type AppLink
  = AppHome
  | AppGallery
  | AppContact
  | AppNotFound String


-- Parses the _fragment_ / hash component of a URI
parseAppLinks : String -> AppLink
parseAppLinks s =
  let parse : String -> AppLink
      parse s' =
        if s' == "home"
        then AppHome
        else if s' == "gallery"
        then AppGallery
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
          AppGallery    -> "gallery"
          AppContact    -> "contact"
          AppNotFound _ -> "not-found"
  in  "#" ++ printed


type alias Links a =
  { toHome    : a
  , toGallery : a
  , toContact : a
  }


notFoundRedirect : AppLink -> a -> Cmd a
notFoundRedirect link toPage =
  case link of
    AppNotFound _ ->
      Task.performLog <|
        (Process.sleep (3 * Time.second)) `Task.andThen` (\_ -> Task.succeed toPage)
    _ -> Cmd.none
