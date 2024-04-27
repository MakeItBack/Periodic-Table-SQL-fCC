#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

ELEMENT_ARG=$1

# Check for an argument passed in when running the file
if [[ ! $ELEMENT_ARG ]];  then
    # No argument
    echo -e "Please provide an element as an argument."

else
    # Look up the argument in the DB to find a matching element
    # Need to join tables and search in multiple columns for match - atomic weight, name or symbol

    PATTERN='^[1-9][0-9]*$'
    if [[ "$ELEMENT_ARG" =~ $PATTERN   ]]
    then
    # Argument is a number so could be an atomic number of an element in db
      FOUND_ELEMENT=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number='$ELEMENT_ARG' ")
    else
    # Argument is a string so could be an element name or symbol for element in db
      FOUND_ELEMENT=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol='$ELEMENT_ARG' OR name='$ELEMENT_ARG' ")
    fi

    if [[ -z $FOUND_ELEMENT ]]; then
      # No matching element found in db
      echo -e "I could not find that element in the database."
    else
      # Found an element
      # Split up the result string into separate variables
      IFS='|' read -r TYPE_ID ATOMIC_NUMBER SYMBOL NAME MASS MELTING_PT BOILING_PT TYPE <<< $FOUND_ELEMENT

      # Print out the element details as required
      echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_PT celsius and a boiling point of $BOILING_PT celsius."
    fi
fi