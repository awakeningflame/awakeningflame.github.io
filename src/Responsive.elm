module Responsive exposing (..)


type WindowSize
  = Mobile
  | Tablet
  | Laptop
  | Desktop


fromWidth : Int -> WindowSize
fromWidth w =
  if w < 723
  then Mobile
  else if w < 933
  then Tablet
  else if w < 1127
  then Laptop
  else Desktop


isMobile : WindowSize -> Bool
isMobile w =
  case w of
    Mobile -> True
    Tablet -> True
    _      -> False
