module Msg exposing (..)
import Keyboard.Extra exposing (Key(..))
import Model
import Time exposing (..)
import List exposing (..)
import Collage exposing (..)


type alias Model =
  Model.Model

type Msg
    = KeyboardMsg Keyboard.Extra.Msg
    | UpdatePlayer1Position Float
    | MovePlayer1 Float
    | UpdatePlayer2Position Float
    | MovePlayer2 Float
    | Tick Time
    | MoveBall
    | CollideBall
    | IncreaseSpeed Time


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of

        Tick newTime ->
          let
            direction1 = getPlayer1Command model.pressedKeys
            direction2 = getPlayer2Command model.pressedKeys
          in
            update (MovePlayer1 direction1) { model | time = newTime }
            |> andThen  (MovePlayer2 direction2)
            |> andThen  (MoveBall)
            |> andThen  (CollideBall)


        IncreaseSpeed newTime ->
          let
            (x,y) = model.ballSpeed
          in
          { model
          | ballSpeed = ((x * 1.01),(y * 1.02))
          , time = newTime
          } ! []

        MoveBall ->
            let
                (positionX, positionY) = model.ballPosition
                (speedX, speedY) = model.ballSpeed
                newBallPosition = (positionX + speedX, positionY + speedY)
                newModel = moveX speedX model.ball
                            |> moveY speedY
            in
                ({model | ball = newModel, ballPosition = newBallPosition}, Cmd.none)

        CollideBall ->
            let
                (positionX, positionY) = model.ballPosition
                (newSpeedX, newSpeedY) =
                    redirectBall model.player1Position model.player2Position model.ballPosition model.ballSpeed
            in
                ({model | ballSpeed = (newSpeedX, newSpeedY)}, Cmd.none)


        MovePlayer1 deslocation ->
          let
            newModel = moveY deslocation model.player1
          in
            case model.player1Position of
              205 -> --   205 = 250 - 45 : limit of where the player can go
                  case deslocation of
                      (-5) ->
                        update (UpdatePlayer1Position deslocation) {model | player1 = newModel}

                      _ ->
                        (model, Cmd.none)

              (-205) ->
                  case deslocation of
                      (-5) ->
                        (model, Cmd.none)

                      _ ->
                        update (UpdatePlayer1Position deslocation) {model | player1 = newModel}


              _ ->
                  update (UpdatePlayer1Position deslocation) {model | player1 = newModel}


        UpdatePlayer1Position deslocation ->
          let
            newModel = model.player1Position + deslocation
          in
            {model | player1Position = newModel} ! []

        MovePlayer2 deslocation ->
          let
            newModel = moveY deslocation model.player2
          in
            case model.player2Position of
              205 -> --   205 = 250 - 45 : limit of where the player can go
                  case deslocation of
                      (-5) ->
                        update (UpdatePlayer2Position deslocation) {model | player2 = newModel}

                      _ ->
                        (model, Cmd.none)

              (-205) ->
                  case deslocation of
                      (-5) ->
                        (model, Cmd.none)

                      _ ->
                        update (UpdatePlayer2Position deslocation) {model | player2 = newModel}


              _ ->
                  update (UpdatePlayer2Position deslocation) {model | player2 = newModel}

        UpdatePlayer2Position deslocation ->
          let
            newModel = model.player2Position + deslocation
          in
            {model | player2Position = newModel} ! []

        KeyboardMsg keyMsg ->
          ( { model | pressedKeys = Keyboard.Extra.update keyMsg model.pressedKeys }
                , Cmd.none
          )

checkCollision : Float -> Float -> (Float, Float) -> Int
checkCollision player1Y player2Y (xBallPosition, yBallPosition) =
    if xBallPosition >= 225 && yBallPosition + 5 >= player2Y - 45 && yBallPosition + 5 <= player2Y + 45 then
        1
    else if xBallPosition <= -225 && yBallPosition - 5 >= player1Y - 45 && yBallPosition - 5 <= player1Y + 45 then
        1
    else if yBallPosition >= 245 || yBallPosition <= -245 then
        2
    else if xBallPosition == 250 || xBallPosition <= -250 then
        3
    else
        0

redirectBall : Float -> Float -> (Float, Float) -> (Float, Float) -> (Float, Float)
redirectBall player1Y player2Y (xBallPosition, yBallPosition) (xBallSpeed, yBallSpeed) =
    let
        hasCollided = checkCollision player1Y player2Y (xBallPosition, yBallPosition)
    in
        case hasCollided of
            1 ->
                (-xBallSpeed, yBallSpeed)
            2 ->
                (xBallSpeed, -yBallSpeed)
            _ ->
                (xBallSpeed, yBallSpeed)

getPlayer1Command : List Key -> Float
getPlayer1Command pressedKeys =
  if member CharW pressedKeys then
      5
  else if member CharS pressedKeys then
      -5
  else
      0

getPlayer2Command : List Key -> Float
getPlayer2Command pressedKeys =
  if member ArrowUp pressedKeys then
      5
  else if member ArrowDown pressedKeys then
      -5
  else
      0

andThen : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen msg ( model, cmd ) =
    let
        ( newmodel, newcmd ) =
            update msg model
    in
        newmodel ! [ cmd, newcmd ]
