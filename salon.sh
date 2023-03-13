#!/bin/bash

PSQL="psql -U freecodecamp -d salon -t -c "

echo -e "\n~~ SALON ~~\n"


MAIN_MENU () {

if [[ $1 ]]
then
echo $1
fi 

echo -e "Welcome. How can I help you?\n"

echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME
do
echo "$SERVICE_ID) $SERVICE_NAME"
done

read SERVICE_ID_SELECTED

if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
MAIN_MENU "Please select a number"
else
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "No such service"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ +| +$//g')
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nWhat's your name"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    SERVICE_NAME=$(echo $SERVICE_NAME | sed -E 's/^ +| +$//g')
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
    echo -e "\nTime?"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi
}

MAIN_MENU

