module Main exposing (..)

import Html exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline


apiUrl : String
apiUrl =
    "http://liveresultat.orientering.se/api.php?method="


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
    { topic : String
    , gifUrl : String
    , competitions : Competitions
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" "waiting.gif" (Competitions [])
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
            ( Model model.topic "" competitions, Cmd.none )

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
    div [] [ text competition.date, text " ", text competition.name ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getCompetitions : Cmd Msg
getCompetitions =
    let
        url =
            apiUrl ++ competitionsUrl
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
