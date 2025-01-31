#!/bin/bash

source ./createTable.sh
source ./listTable.sh
source ./dropTable.sh

DB_DIR="databases"
mkdir -p "$DB_DIR"

main_menu() {
    while true; do
        choice=$(dialog --title "DBMS" --menu "Choose an option:" 15 50 5 \
            1 "Create Database" \
            2 "List Databases" \
            3 "Connect to Database" \
            4 "Drop Database" \
            5 "Exit" --output-fd 1)

         EXIT_STATUS=$?

      if [ $EXIT_STATUS -ne 0 ] 
      then 
         dialog --msgbox "Closing DBMS..." 10 25
         clear; exit 0
         break
      fi  
        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_to_database ;;
            4) drop_database ;;
            5) clear; exit 0 ;;
        esac
    done
}


create_database() {
    db_name=$(dialog --inputbox "Enter database name:" 10 40 --output-fd 1)
    if [[ -z $db_name ]]; then
      dialog --msgbox "Database name cannot be empty!" 10 30
      return 1
    fi
    if [ -d $DB_DIR/$db_name ]; then
        dialog --msgbox "Error: Database '$db_name' already exists." 10 30
        return
    fi
    if [[ ! $db_name =~ ^[a-zA-Z_]+$ ]]; then
        dialog --msgbox "Invalid database name!" 10 30
        return
    fi

    mkdir -p $DB_DIR/$db_name && dialog --msgbox "Database created successfully!" 10 30
}

list_databases() {
    db_list=$(ls "$DB_DIR" 2>/dev/null)
    dialog --msgbox "Databases:\n$db_list" 15 40
}

connect_to_database() {
    db_name=$(dialog --inputbox "Enter database name to connect:" 10 40 --output-fd 1)
    if [ -d "$DB_DIR/$db_name" ]; then
        database_table_menu $db_name
    else
        dialog --msgbox "Database not found!" 10 30
    fi
}


database_table_menu() {
    local db_name=$1
    while true; do
        choice=$(dialog --title "Database Table Menu: $db_name" --menu "Choose an option:" 15 50 6 \
            1 "Create Table" \
            2 "List Tables" \
            3 "Drop Table" \
            4 "Insert into Table" \
            5 "Select from Table" \
            6 "Update from Table" \
            7 "Delete from Table" \
            8 "Back to Main Menu" --output-fd 1)
         EXIT_STATUS=$?

      if [ $EXIT_STATUS -ne 0 ] 
      then 
         dialog --msgbox "Going back to main database menu ..." 10 25
         break
      fi   
        case $choice in
            1) create_table "$DB_DIR" "$db_name" ;;
            2) list_tables "$DB_DIR" "$db_name" ;;
            3) drop_table "$DB_DIR" "$db_name" ;;
            4) insert_into_table "$db_name" ;;
            5) select_from_table "$db_name" ;;
            6) update_from_table "$db_name" ;;
            7) delete_from_table "$db_name" ;;
            8) break ;;
        esac
    done
}

main_menu