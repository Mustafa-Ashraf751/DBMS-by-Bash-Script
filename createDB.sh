#!/bin/bash

create_database() {
    db_name=$(dialog --inputbox "Enter database name:" 10 40 --output-fd 1)

    EXIT_STATUS=$?
    if [ $EXIT_STATUS -ne 0 ]; then
        dialog --msgbox "Going back to database menu ..." 10 40
        return
    fi


    if [[ -z $db_name ]]; then
      dialog --msgbox "Database name cannot be empty!" 10 30
      return
    fi
    if [ -d $DB_DIR/$db_name ]; then
        dialog --msgbox "Error: Database '$db_name' already exists." 10 30
        return
    fi
    if [[ ! $db_name =~ ^[a-zA-Z_]+$ ]]; then
        dialog --msgbox "Invalid database name!" 10 30
        return
    fi

    mkdir -p $DB_DIR/$db_name
    dialog --msgbox "Database created successfully!" 10 30
}
