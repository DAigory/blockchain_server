module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)

import Http
import Json.Encode
import Debug

import Project.Models exposing (Project, Reward)
import Project.Commands exposing (..)

import Style exposing (..)

-- MODEL

type alias Model =
    { projects : List Project
    , addProjectWindowFlag: Bool
    , newProject: Project
    , newReward: Reward
    , selectedProjectId: Int
    , getFlag: Bool
    }


-- INIT
init : (Model, Cmd Msg)
init = (Model  [] False initProject initReward 0 False, fetchProjects)

-- UPDATE

type Msg = Nothing
         | ProjectMsg Project.Commands.Msg
         | AddProjectWindow
         | NewProject | NewProjectName String | NewProjectDescription String | NewProjectTarget String
         | NewReward | NewRewardName String| NewRewardCost String
         | Cancel
         | PostProject (Result Http.Error Project)
         | GetDonateButton Int
         | SelectProject Int
         | CloseDonateButton

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ProjectMsg action ->
            case action of
                Fetch (Ok projs) ->
                    ({model | projects = projs}, Cmd.none)

                Fetch (Err err) ->
                    let _ = Debug.log "Project info fail" err in (model, Cmd.none)

        AddProjectWindow ->
            ({model | addProjectWindowFlag  = True}, Cmd.none)

        NewProject ->
            ({ model | newProject = initProject}, postProject model.newProject)

        NewProjectName name ->
            let project = model.newProject
                newProject = {project | name = name}
            in
            ({model | newProject  = newProject}, Cmd.none)

        NewProjectDescription description ->
            let project = model.newProject
                newProject = {project | description = description}
            in
            ({model | newProject  = newProject}, Cmd.none)

        NewProjectTarget target ->
            let project = model.newProject
                newProject = {project | target = Result.withDefault 0 (String.toInt target)}
            in
            ({model | newProject  = newProject}, Cmd.none)

        NewReward ->
            let project = model.newProject
                newReward = model.newReward
                rewards = project.rewards
                newRewards = newReward :: rewards
                newProject = {project | rewards = newRewards}
            in
            ({model | newProject  = newProject
                     , newReward = initReward }, Cmd.none)

        NewRewardName name ->
            let reward = model.newReward
                newReward = {reward | name = name}
            in
            ({model | newReward  = newReward}, Cmd.none)

        NewRewardCost cost ->
            let reward = model.newReward
                newReward = {reward | cost = Result.withDefault 0 (String.toInt cost)}
            in
            ({model | newReward  = newReward}, Cmd.none)

        Cancel ->
            ({model | addProjectWindowFlag  = False}, Cmd.none)

        PostProject (Ok answer) ->
            ({model | addProjectWindowFlag  = False}, fetchProjects)

        PostProject (Err err) ->
            let _ = Debug.log "Project info fail" err
            in
            ({model | addProjectWindowFlag  = False}, Cmd.none)

        GetDonateButton projectId ->
            ({model | getFlag = True }, Cmd.none)

        SelectProject projectId ->
            ({model | selectedProjectId  = projectId
                    , getFlag = False
            }, Cmd.none)

        CloseDonateButton ->
            ({model | selectedProjectId  = 0
                    , getFlag = False
            }, Cmd.none)

        _ -> (model, Cmd.none)


fetchProjects : Cmd Msg
fetchProjects = Cmd.map ProjectMsg Project.Commands.fetchProjects

postProject : Project -> Cmd Msg
postProject project =
    Http.send PostProject
    <| Http.post "http://localhost:3000/projects" (formNewProjectBody project) projectDecoder


formNewProjectBody: Project -> Http.Body
formNewProjectBody newProject =
    Http.jsonBody
    <| Json.Encode.object
        [ ("name",  Json.Encode.string newProject.name)
        , ("description", Json.Encode.string newProject.description)
        , ("target", Json.Encode.int newProject.target)
        , ("rewards", Json.Encode.list <| List.map (\l -> encodeReward l) newProject.rewards)
        , ("id", Json.Encode.int newProject.id)
        ]

encodeReward: Reward -> Json.Encode.Value
encodeReward newReward =
    Json.Encode.object
        [ ("name",  Json.Encode.string newReward.name)
        , ("cost", Json.Encode.int newReward.cost)
        , ("id", Json.Encode.int newReward.id)
        ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- VIEW

view : Model -> Html Msg
view {projects, addProjectWindowFlag, newProject, newReward, selectedProjectId, getFlag} =
    body []
        [ div [ headerContainerStyle, onClick <| CloseDonateButton][
            div [ class "container"][
                h1 [headerWhiteStyle][ text " Краудфандинг"]
              , p [][text "Добро пожаловать на страницу краудфаунинга, использующего систему блокчейн."]
              ]]
        , div [ class "container" ]
              [ table [class "table table-hover"]
                [ thead []
                    [ tr []
                      [ th [] [text "Название"]
                      , th [] [text "Описание"]
                      ]]
                , tbody []
                    <| List.map (\l -> viewProject l selectedProjectId) projects
                ]
                , button [class "btn btn-primary", onClick AddProjectWindow][ text "Добавить проект"]
              ]
          , if (addProjectWindowFlag) then
              div [ class "container", fullStyle][
                div [ class "container", addContainerStyle]
                    [ h2[][text "Добавить проект"]
                    , Html.form []
                        [ div [class "form-group"]
                            [ label [][text "Название"]
                            , input [class "form-control", placeholder "Название", onInput NewProjectName][]
                            ]
                          , div [class "form-group"]
                              [ label [][text "Описание"]
                              , textarea [class "form-control", placeholder "Описание", rows 3, onInput NewProjectDescription][]
                              ]
                          , div [class "form-group"]
                            [ label [][text "Цель"]
                            , div [class "input-group", style [("width","200px")]]
                               [ div [class "input-group-addon"][text "$"]
                               , input [class "form-control", placeholder "Сумма", onInput NewProjectTarget][]
                               , div [class "input-group-addon"][ text ".00"]
                            ]]
                        , div [class "form-group", style [("width","400px")]]
                          [ label [][text "Награды"]
                          , ul [class "list-group"]
                              <| List.append
                               (List.map (\l-> viewReward l) newProject.rewards)
                              [ li [class "list-group-item form-inline"]
                                [ input [class "form-control input-sm", placeholder "Награда", style [("width","150px")], onInput NewRewardName][]
                                , button [class "btn btn-success btn-sm pull-right", onClick NewReward , type_ "button"][text "+"]
                                , div [class "input-group", style [("width","100px"), ("margin-left", "20px")]]
                                     [ div [class "input-group-addon input-sm"][text "$"]
                                     , input [class "form-control input-sm", placeholder "Сумма", onInput NewRewardCost][]
                                     ]
                                ]
                              ]]
                        , p [ class "pull-right"]
                            [ button [class "btn btn-default", style [("margin-right", "10px")], onClick Cancel, type_ "button"][text "Отмена"]
                            , button [class "btn btn-success", onClick NewProject,  type_ "button"][text "Добавить"]
                            ]
                        ]]]
          else
              div[][]
          , if (getFlag) then
              div [ class "container", fullStyle][
                div [ class "container", addContainerStyle, style [("max-width","700px")]]
                    [ let project = Maybe.withDefault initProject <| List.head <| List.filter (\l->l.id == selectedProjectId) projects
                    in
                    textarea[style [("width","100%")], rows 20][text <| generateButtonCode project.name project.rewards]
                    , p [ class "pull-right"]
                        [ button [class "btn btn-default", style [("margin-right", "10px")], onClick CloseDonateButton, type_ "button"][text "ОK"]
                    ]]]
          else
              div[][]
        ]

viewReward : Reward -> Html Msg
viewReward reward =
    li [class "list-group-item"]
        [ span [class "badge"][text <|(toString reward.cost) ++ "$"]
        , text reward.name
        ]

viewProject : Project -> Int -> Html Msg
viewProject project selectedProjectId =
    tr [ if (project.id == selectedProjectId) then onClick Nothing else onClick <| SelectProject project.id]
      [ td [] [span [] [text project.name]]
      , td [] [text project.description
          , (if (project.id == selectedProjectId) then
              p[ style [("margin-top", "20px")]][
                button [class "btn-success", onClick <| GetDonateButton project.id,  type_ "button"]
                    [text "Получить код виджета"]]
          else div[][])
      ]]


generateButtonCode : String -> List Reward -> String
generateButtonCode name rewards =
  """
   <script src=\"main.js\"></script>
    <div id=\"donate-widget\">
    </div>
    <script>
      var widget_div = document.getElementById('donate-widget');
      Elm.Main.embed(widget_div, {
        projectName: ' """
   ++ name
   ++ "', rewards: [" ++ (List.foldr (\{name, cost} acc -> acc ++ "{\"name\" : \"" ++ name ++ "\", \"cost\": " ++ toString cost ++ "},") "" rewards)
   ++
   """
   ]
   });
   </script>
   """


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions }
