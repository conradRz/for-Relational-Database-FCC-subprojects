#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

# Function to display services
DISPLAY_SERVICES() {
  echo -e "Welcome! Here are the services we offer:\n"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS="|" read -r SERVICE_ID NAME; do
    echo "$SERVICE_ID) $NAME"
  done
}

MAIN_MENU() {
  DISPLAY_SERVICES

  # Prompt user for service selection
  echo -e "\nPlease select a service by entering its number:"
  read SERVICE_ID_SELECTED

  # Validate service selection
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo "$SERVICE_NAME" | sed 's/^[ \t]*//;s/[ \t]*$//')  # Trim whitespace

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service. Please try again.\n"
    MAIN_MENU
  else
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed 's/^[ \t]*//;s/[ \t]*$//')  # Trim whitespace

    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "\nIt seems you are a new customer. Please enter your name:"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # Get customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_ID=$(echo "$CUSTOMER_ID" | sed 's/^[ \t]*//;s/[ \t]*$//')  # Trim whitespace

    echo -e "\nWhat time would you like your appointment?"
    read SERVICE_TIME

    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU

