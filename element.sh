#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to get element information
GET_INFO() {
  local QUERY=""
  if [[ $1 =~ ^[0-9]+$ ]]; then
    # Atomic number
    QUERY="atomic_number = $1"
  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]; then
    # Symbol (one or two characters)
    QUERY="symbol = '$1'"
  else
    # Name with proper capitalization
    QUERY="name = '$(echo "$1" | sed -E 's/^([a-z])/\u\1/')'"
  fi

  # Fetch element details
  $PSQL "SELECT atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         JOIN properties p USING(atomic_number)
         JOIN types t USING(type_id)
         WHERE $QUERY"
}

# Main script logic
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Get element information
INFOS=$(GET_INFO "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# Check if the element exists
if [[ -z $INFOS ]]; then
  echo "I could not find that element in the database."
else
  # Parse the result
  IFS='|' read -r atomic_number name symbol type atomic_mass melting_point_celsius boiling_point_celsius <<< "$INFOS"

  # Output the result
  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
fi
