#!/bin/bash

# Program to create a number guessing game

# database will need to store:
# 1) username (varchar 22 length) <username>
# 2) number of games the user has played <games_played>
# 3) fewest number of guesses in a game session <best game>
# 4) user_id

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo -e "\nWelcome to the Number Guessing Game!!\n"

echo -e "Enter your username:\n"
read USERNAME

USERNAMEQUERY=$($PSQL "SELECT * FROM users WHERE name='$USERNAME'")

if [[  -z $USERNAMEQUERY  ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # echo $USERNAMEQUERY
  echo $USERNAMEQUERY | while IFS="|" read USER_ID NAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi





# Create a random number
N=$(( RANDOM%1000 + 1 ))
echo "Random Number is: $N"


# Ask user to guess
echo "Guess the secret number between 1 and 1000:"
read GUESS
GUESS_COUNT=1


while [[ ! $GUESS =~ ^[0-9]+$ || $GUESS -ne $N ]]
do
  if [[  ! $GUESS =~ ^[0-9]+$  ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    (( GUESS_COUNT++ ))
  else
    if [[  $GUESS -lt $N  ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
      ((  GUESS_COUNT++ ))
    else
      echo "It's higher than that, guess again:"
      read GUESS
      ((  GUESS_COUNT++ ))
    fi
  fi
done

if [[ -z $USERNAMEQUERY ]]
then
  DBENTRY=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USERNAME', 1, $GUESS_COUNT)")
else
  echo $USERNAMEQUERY | while IFS="|" read USER_ID NAME GAMES_PLAYED BEST_GAME
  do
    ((  GAMES_PLAYED++  ))
    GAMES_UPDATE=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE name='$USERNAME'")
    if [[ $GUESS_COUNT -lt $BEST_GAME ]]
    then
      BEST_GAME_UPDATE=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE name='$USERNAME'")
    fi
  done
fi



echo "You guessed it in $GUESS_COUNT tries. The secret number was $N. Nice job!"




# At end, add name to db. Get games played, increment by one, write to db.
# write the total number of guesses if its fewer than what's there or if NULL in db.




