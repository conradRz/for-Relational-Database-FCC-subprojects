#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# to have a clean start
echo "$($PSQL "TRUNCATE teams, games")"

cat games.csv | while IFS="," read year round WINNER OPPONENT winner_goals opponent_goals
do
	if [[ $WINNER != "winner" ]] 
	then
		echo "$($PSQL "INSERT INTO teams(name) values ('$WINNER') ON CONFLICT (name) DO NOTHING")" 
		echo "$($PSQL "INSERT INTO teams(name) values ('$OPPONENT') ON CONFLICT (name) DO NOTHING")" 
		
		winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
		opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
		echo "$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) values ('$year','$round','$winner_id','$opponent_id','$winner_goals','$opponent_goals')")" 
	
	fi
done
