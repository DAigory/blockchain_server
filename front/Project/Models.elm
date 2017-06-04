module Project.Models exposing (..)


type alias Reward =
    { name : String
    , cost : Int
    , id : Int
    }


type alias Project =
    { name : String
    , description : String
    , target : Int
    , rewards : List Reward
    , id : Int
    }
