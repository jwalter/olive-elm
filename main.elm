module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, href)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline
import Api


competitionsUrl : String
competitionsUrl =
    "getcompetitions"


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Competitions =
    { competitions : List Competition }


type alias Competition =
    { id : Int
    , name : String
    , organizer : String
    , date : String
    , timediff : Int
    }


type alias Model =
    { competitions : Competitions
    }


init : ( Model, Cmd Msg )
init =
    ( Model (Competitions [])
    , getCompetitions
    )



-- UPDATE


type Msg
    = MorePlease
    | NewGif (Result Http.Error Competitions)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MorePlease ->
            ( model, getCompetitions )

        NewGif (Ok competitions) ->
            ( Model competitions, Cmd.none )

        NewGif (Err _) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "o-Live" ]
        , div [] (List.map comp model.competitions.competitions)
        ]


comp : Competition -> Html Msg
comp competition =
    div [ style [ ( "display", "flex" ) ] ]
        [ div [] [ text competition.date ]
        , div [] [ a [ href ("http://www.dn.se?id=" ++ toString competition.id) ] [ text competition.name ] ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getCompetitions : Cmd Msg
getCompetitions =
    let
        url =
            Api.rootUrl ++ competitionsUrl
    in
        Http.send NewGif (Http.get url decodeCompetitions)


decodeCompetitions : Decode.Decoder Competitions
decodeCompetitions =
    Json.Decode.Pipeline.decode Competitions
        |> Json.Decode.Pipeline.required "competitions" (Decode.list decodeCompetition)


decodeCompetition : Decode.Decoder Competition
decodeCompetition =
    Json.Decode.Pipeline.decode Competition
        |> Json.Decode.Pipeline.required "id" (Decode.int)
        |> Json.Decode.Pipeline.required "name" (Decode.string)
        |> Json.Decode.Pipeline.required "organizer" (Decode.string)
        |> Json.Decode.Pipeline.required "date" (Decode.string)
        |> Json.Decode.Pipeline.required "timediff" (Decode.int)
