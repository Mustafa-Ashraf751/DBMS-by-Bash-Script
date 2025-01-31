#!/bin/bash

connect_to_database() {
    db_name=$(dialog --inputbox "Enter database name to connect:" 10 40 --output-fd 1)
    if [[ -z $db_name ]]; then
      dialog --msgbox "Database name cannot be empty!" 10 30
      return
    fi
    if [ -d "$DB_DIR/$db_name" ]; then
        database_table_menu $db_name
    else
        dialog --msgbox "Database not found!" 10 30
    fi
}
