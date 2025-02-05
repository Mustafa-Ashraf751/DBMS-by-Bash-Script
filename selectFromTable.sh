#!/bin/bash

select_from_table() {
    db_name=$1
 while true; do 
    table_name=$(dialog --inputbox "Enter table name:" 10 40 --output-fd 1)

    if [[ -z $table_name ]]; then
        dialog --msgbox "Table name cannot be empty!" 10 40
        continue
    fi
    if [[ ! $table_name =~ ^[a-zA-Z_]+$ ]]; then    
    dialog --msgbox "Invalid table name please try again!" 10 40
    continue
    fi
    table_path="$DB_DIR/$db_name/$table_name/$table_name.csv"
    meta_path="$DB_DIR/$db_name/$table_name/$table_name.meta"

    if [[ ! -f $table_path ]] || [[ ! -f $meta_path ]]; then
        dialog --msgbox "Table does not exist!" 10 40
        continue
    fi
   
    pk_column=""
    pk_index=-1
    index=0

    while IFS=: read -r col_name col_type col_flag; do
        if [[ "$col_flag" == "primaryKey" ]]; then
            pk_column="$col_name"
            pk_index=$index
            break
        fi
        ((index++))
    done < "$meta_path"

    if [[ -z $pk_column ]]; then
        dialog --msgbox "No primary key defined in table!" 10 40
        continue
    fi
    break
 done
    choice=$(dialog --title "Select option for table:  $table_name" --menu "Choose an option"  15 50 6 \1 "Select all data from the table" \
      2 "Select row data by primary key" \
       --output-fd 1)
      EXIT_STATUS=$?

      if [ $EXIT_STATUS -ne 0 ]; then 
      dialog --msgbox "Going back to table menu ..." 10 40
      return 1
      fi

    if [ "$choice" == 1 ]; then
    content=$(cat "$table_path")
    dialog --msgbox "$content" 20 80
    elif [ "$choice" == 2 ]; then   

     pk_value=$(dialog --inputbox "Enter the primary key value to select:" 10 40 --output-fd 1)

     if [[ -z $pk_value ]]; then
        dialog --msgbox "Primary key value cannot be empty!" 10 40
        return
     fi

     row_found=""
     while IFS=: read -r -a row; do
        if [[ "${row[$pk_index]}" == "$pk_value" ]]; then
            row_found="${row[*]}"
            break
        fi
     done < "$table_path"

     if [[ -z $row_found ]]; then
        dialog --msgbox "No record found with primary key: $pk_value" 10 40
        return
     fi

     dialog --msgbox "Selected Record:\n$row_found" 10 40
   fi 
}
