module View exposing (..)
import Msg
import Model
import Html exposing (Html, text, div, img)
import Html.Attributes exposing (src, style)
import Html exposing (Html)
import Element exposing (..)
import Style exposing (..)
import Collage exposing (..)
import Keyboard.Extra exposing (..)

type alias Model =
  Model.Model

type alias Msg =
  Msg.Msg


view : Model -> Html Msg
view model =
    let
      wasd =
        Keyboard.Extra.wasd model.pressedKeys
    in
      div [style backgroundStyle]
          [ div [style scoreStyle]
                [ div [] [ Html.text (toString model.p1Score) ]
                , div [] [Html.text "x"]
                , div [] [ Html.text (toString model.p2Score) ]
                ]
          , toHtml ( Collage.collage 500 500 [model.background , model.player1, model.player2, model.obstacle, model.ball] )
          ]
