#!/bin/bash

connect_to_database() {
    while true; do
        db_name=$(dialog --inputbox "Enter database name to connect:" 10 40 --output-fd 1)

        EXIT_STATUS=$?
        if [ $EXIT_STATUS -ne 0 ]; then
            dialog --msgbox "Returning to database menu..." 10 40
            return 1
        fi

        if [[ -z $db_name ]]; then
            dialog --msgbox "Database name cannot be empty!" 10 30
            continue
        fi


        if [ -d "$DB_DIR/$db_name" ]; then
            database_table_menu "$db_name"
            break
        else
            dialog --msgbox "Database not found!" 10 30
            continue
        fi
    done
}