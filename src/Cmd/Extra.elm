module Cmd.Extra exposing (..)

import Task exposing (Task)



performLog : Task e a -> Cmd a
performLog = Task.perform (Debug.crash << toString) identity


mkCmd : a -> Cmd a
mkCmd = performLog << Task.succeed
