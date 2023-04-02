#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
echo -e "\n~~~~~ My Salon ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"
MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id , name FROM services")
  echo $SERVICES | sed -r 's/([0-9]+)\|([a-zA-Z]+)/\n\1\) \2/g'
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
  1 | 2 | 3) CREATE_APPOINTMENT $SERVICE_ID_SELECTED;;
  *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}
CREATE_APPOINTMENT(){
  SERVICE_ID_SELECTED=$(echo $1)
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # get user phone
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # insert customer
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone)VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  # get time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  # insert appointment
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time)VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT_RESULT ]]
  then
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
MAIN_MENU
