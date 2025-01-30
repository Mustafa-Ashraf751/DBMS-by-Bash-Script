#!/bin/bash

list_tables() {
  DB_DIR="$1"
  DB_Name="$2"

  if [ ! -d "$DB_DIR/$DB_Name" ]; then
    dialog --msgbox "Database not found!" 10 30
    return 1
  fi

  tables=$(ls -d "$DB_DIR/$DB_Name"/*/ 2>/dev/null | awk -F '/' '{print $(NF-1)}')

  if [ -z "$tables" ]; then 
    dialog --msgbox "No tables found in the database!" 10 30
    return 1
  else
    dialog --msgbox "Tables in database $DB_Name:\n$tables" 15 40 
  fi

}