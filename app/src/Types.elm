module Types exposing (..)
import Http exposing (..)

type alias Person =
    { name : String
    , height : String
    , mass : String
    , gender : String
    , url : String
    }

type Msg
    = PersonsLoadedMsg (Result Http.Error (List Person))
    | SelectedPersonLoaded (Result Http.Error Person)
    | OnPersonClick String 
