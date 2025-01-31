#!/bin/bash

drop_table() {
  DB_DIR="$1"
  DB_Name="$2"

  tables=$(ls -d "$DB_DIR/$DB_Name"/*/ 2>/dev/null | awk -F '/' '{print $(NF-1)}')

  if [ -z "$tables" ]; then 
    dialog --msgbox "No tables found in the database to drop!" 10 40
    return 1
  fi  

while true; do
  table_name=$(dialog --inputbox "Enter the name of table to drop:" 10 40 --output-fd 1)
  EXIT_STATUS=$?

  if [ $EXIT_STATUS -ne 0 ]; then
  dialog --msgbox "Going back to table menu ..." 10 40
  return 1
  fi

  if [[ -z $table_name ]]; then
   dialog --msgbox "Table name cannot be empty!" 10 40
   continue
  fi

  if [[ ! $table_name =~ ^[a-zA-Z_]+$ ]]; then
   dialog --msgbox "Invalid table name!" 10 40
   continue
  fi

  if [ -d "$DB_DIR/$DB_Name/$table_name" ]; then
   dialog --yesno "Are you sure you want to drop table '$table_name'?" 10 30
   if [ $? -eq 0 ]; then
    rm -rf "$DB_DIR/$DB_Name/$table_name"
     dialog --msgbox "Table '$table_name' dropped successfully!" 10 30
     return 0
   fi
  else
    dialog --msgbox "Table '$table_name' does not exist in the database!" 10 30
    continue
  fi
done  

}