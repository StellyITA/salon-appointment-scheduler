#!/bin/bash

echo -e "\n~~~ Welcome to Elixhair appointment scheduler ~~~\n"

PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWhich service would you like to book?"
  SERVICES=$($PSQL "SELECT service_id,name FROM services")
  echo "$SERVICES" | while read ID BAR NAME
  do
    echo -e "$ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ [1-3] ]]
  then
    MAIN_MENU "Please input a valid service number."
  else
    BOOK
  fi
}

BOOK () {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    ADD_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo -e "\nSelect a time for the service you would like to book, $CUSTOMER_NAME"
  read SERVICE_TIME
  ADD_SERVICE=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." | sed -r 's/ +/ /g'
}

MAIN_MENU
