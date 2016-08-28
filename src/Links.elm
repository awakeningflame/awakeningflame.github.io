module Links exposing (..)

import String
import Time
import Cmd.Extra as Task
import Task
import Process


type AppLink
  = AppHome
  | AppNotFound String


-- Parses the _fragment_ / hash component of a URI
parseAppLinks : String -> AppLink
parseAppLinks s =
  let parse : String -> AppLink
      parse s' =
        if s' == "home"
        then AppHome
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
          AppHome -> "home"
          AppNotFound _ -> "not-found"
  in  "#" ++ printed


type alias Links a =
  { toHome : a
  }


notFoundRedirect : AppLink -> a -> Cmd a
notFoundRedirect link toPage =
  case link of
    AppNotFound _ ->
      Task.performLog <|
        (Process.sleep Time.second) `Task.andThen` (\_ -> Task.succeed toPage)
    _ -> Cmd.none