#!/bin/bash

drop_database() {
    db_name=$(dialog --inputbox "Enter database name to drop:" 10 40 --output-fd 1)

    EXIT_STATUS=$?
    if [ $EXIT_STATUS -ne 0 ]; then
        dialog --msgbox "Going back to database menu ..." 10 40
        return
    fi

    if [[ -z $db_name ]]; then
        dialog --msgbox "Database name cannot be empty!" 10 30
        return
    fi

    db_path="$DB_DIR/$db_name"

    if [[ ! -d $db_path ]]; then
        dialog --msgbox "Error: Database '$db_name' does not exist." 10 30
        return
    fi

    rm -r "$db_path"
    dialog --msgbox "Database '$db_name' deleted successfully!" 10 30
}
