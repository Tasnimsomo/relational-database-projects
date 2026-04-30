#!/bin/bash
# periodic table lookup script
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# no argument
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi


# number input
if [[ $1 =~ ^[0-9]+$ ]]
then
  RESULT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol,
  t.type, p.atomic_mass,
  p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE e.atomic_number = $1;
  ")
  
else
  RESULT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol,
  t.type, p.atomic_mass,
  p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE LOWER(e.symbol) = LOWER('$1')
     OR LOWER(e.name) = LOWER('$1');
  ")
fi

# no result
if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MP BP <<< "$RESULT"

  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
fi