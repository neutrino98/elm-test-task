module State exposing (..)

import Navigation exposing (Location)
import Request.Person as PersonRequest exposing (..)
import Routing exposing (..)
import Task exposing (Task)
import Types exposing (..)
import Utils exposing (..)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.extractRoute location
    in
    ( initialModel currentRoute, Task.attempt PersonsLoaded PersonRequest.getPersons )


emptyPerson : Person
emptyPerson =
    Person "" "" "" "" ""


initialModel : Route -> Model
initialModel route =
    { plist = []
    , currentPerson = emptyPerson
    , error = Nothing
    , currentRoute = route
    , loading = True
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PersonsFetch ->
            ( { model | plist = [] }, Task.attempt PersonsLoaded PersonRequest.getPersons )

        PersonsLoaded (Ok list) ->
            ( { model | plist = list, loading = False }, Cmd.none )

        PersonsLoaded (Err error) ->
            ( { model | error = Just (toString error), loading = False }, Cmd.none )

        SelectedPersonLoaded (Ok person) ->
            ( { model | currentPerson = person, loading = False }, Cmd.none )

        SelectedPersonLoaded (Err error) ->
            ( { model | error = Just (toString error), loading = False }, Cmd.none )

        OnPersonClick url ->
            let
                id =
                    case getIdFromUrl url 2 of
                        Nothing ->
                            Debug.crash "!!!"

                        Just s ->
                            s
            in
            ( { model
                | loading = True
              }
            , Cmd.batch
                [ Task.attempt SelectedPersonLoaded (PersonRequest.getPersonById url)
                , Navigation.newUrl ("/people/" ++ id)
                ]
            )

        LocationChanged location ->
            let
                nextRoute =
                    Routing.extractRoute location

                str =
                    getIdFromUrl model.currentPerson.url 2

                command =
                    case nextRoute of
                        PersonRoute str ->
                            Task.attempt SelectedPersonLoaded (PersonRequest.getPersonById model.currentPerson.url)

                        _ ->
                            Cmd.none
            in
            ( { model
                | currentRoute = nextRoute
                , currentPerson =
                    if nextRoute == LandingPageRoute then
                        emptyPerson
                    else
                        model.currentPerson
              }
            , command
            )
