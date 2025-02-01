#!/bin/bash

source ./createDB.sh
source ./listDBs.sh
source ./connectToDB.sh
source ./dropDB.sh

source ./createTable.sh
source ./listTables.sh
source ./dropTable.sh
source ./deleteFromTable.sh
source ./selectFromTable.sh

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