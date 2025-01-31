#!/bin/bash

drop_table() {
  DB_DIR="$1"
  DB_Name="$2"

  table_name=$(dialog --inputbox "Enter the name of table to drop:" 10 40 --output-fd 1)

  if [ -d "$DB_DIR/$DB_Name/$table_name" ]; then
   dialog --yesno "Are you sure you want to drop table '$table_name'?" 10 30
   if [ $? -eq 0 ]; then
    rm -rf "$DB_DIR/$DB_Name/$table_name"
     dialog --msgbox "Table '$table_name' dropped successfully!" 10 30
   fi
  else
    dialog --msgbox "Table '$table_name' does not exist in the database!" 10 30
  fi


}