#!/bin/bash

select_from_table() {
    db_name=$1
    table_name=$(dialog --inputbox "Enter table name:" 10 40 --output-fd 1)

    if [[ -z $table_name ]]; then
        dialog --msgbox "Table name cannot be empty!" 10 40
        return
    fi

    table_path="$DB_DIR/$db_name/$table_name/$table_name.csv"
    meta_path="$DB_DIR/$db_name/$table_name/$table_name.meta"

    if [[ ! -f $table_path ]] || [[ ! -f $meta_path ]]; then
        dialog --msgbox "Table does not exist!" 10 40
        return
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
        return
    fi

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
}
