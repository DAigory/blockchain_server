module Project.Commands exposing (..)

import Http
import Task
import Json.Decode exposing (..)
import Json.Decode.Extra exposing ((|:))

import Project.Models exposing (Project, Reward)


resourceUrl : String
resourceUrl =
    "http://localhost:3000/projects"


initProject: Project
initProject =
    { name = ""
    , description = ""
    , target = 0
    , rewards = []
    , id = 0
    }


initReward: Reward
initReward =
    { name =  ""
    , cost = 0
    , id  = 0
    }


projectDecoder : Json.Decode.Decoder Project
projectDecoder =
    Json.Decode.succeed Project
        |: (field "name" Json.Decode.string)
        |: (field "description" Json.Decode.string)
        |: (field "target" Json.Decode.int)
        |: (field "rewards" <| Json.Decode.list rewardDecoder)
        |: (field "id" Json.Decode.int)



rewardDecoder : Json.Decode.Decoder Reward
rewardDecoder =
    Json.Decode.succeed Reward
        |: (field "name" Json.Decode.string)
        |: (field "cost" Json.Decode.int)
        |: (field "id" Json.Decode.int)



type Msg = Fetch (Result Http.Error (List Project))


fetchProjects : Cmd Msg
fetchProjects =
    Http.send Fetch
    <| Http.get resourceUrl <| Json.Decode.list projectDecoder
