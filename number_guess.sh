#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))

  if (( GUESS == SECRET_NUMBER ))
  then
    break
  fi

  if (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

NEW_GAMES=$(( GAMES_PLAYED + 1 ))

if [[ $BEST_GAME == 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  UPDATE=$($PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
else
  UPDATE=$($PSQL "UPDATE users SET games_played=$NEW_GAMES WHERE username='$USERNAME'")
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
