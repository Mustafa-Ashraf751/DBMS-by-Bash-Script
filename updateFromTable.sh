#!/bin/bash

update_from_table() {
    db_name=$1

    while true; do
        table_name=$(dialog --inputbox "Enter table name:" 10 40 --output-fd 1)
        EXIT_STATUS=$?


        if [ $EXIT_STATUS -ne 0 ]; then
            dialog --msgbox "Returning to table menu..." 10 40
            return 1
        fi


        if [[ -z $table_name ]]; then
            dialog --msgbox "Table name cannot be empty!" 10 40
            continue
        fi


        table_path="$DB_DIR/$db_name/$table_name/$table_name.csv"
        meta_path="$DB_DIR/$db_name/$table_name/$table_name.meta"
        if [[ ! -f $table_path ]] || [[ ! -f $meta_path ]]; then
            dialog --msgbox "Table does not exist!" 10 40
            continue
        fi

        break
    done


    pk_column=""
    pk_index=-1
    index=0
    declare -a column_names
    declare -a column_types
    declare -a column_constraints

    while IFS=: read -r col_name col_type col_flag; do
        column_names[index]=$col_name
        column_types[index]=$col_type
        column_constraints[index]=$col_flag
        if [[ "$col_flag" == "primaryKey" ]]; then
            pk_column="$col_name"
            pk_index=$index
        fi
        ((index++))
    done < "$meta_path"


    while true; do
        pk_value=$(dialog --inputbox "Enter the primary key value:" 10 40 --output-fd 1)
        EXIT_STATUS=$?


        if [ $EXIT_STATUS -ne 0 ]; then
            dialog --msgbox "Returning to table menu..." 10 40
            return 1
        fi


        if [[ -z $pk_value ]]; then
            dialog --msgbox "Primary key value cannot be empty!" 10 40
            continue
        fi


        row_to_update=""
        line_number=0
        while IFS=: read -r -a row; do
            ((line_number++))
            if [[ "${row[$pk_index]}" == "$pk_value" ]]; then
                row_to_update=$line_number
                break
            fi
        done < "$table_path"

        if [[ -z $row_to_update ]]; then
            dialog --msgbox "No record found with primary key: $pk_value" 10 40
            continue
        fi

        break
    done


    while true; do
        col_name_to_update=$(dialog --inputbox "Enter column name to update:" 10 40 --output-fd 1)
        EXIT_STATUS=$?


        if [ $EXIT_STATUS -ne 0 ]; then
            dialog --msgbox "Returning to table menu..." 10 40
            return 1
        fi


        col_index=-1
        col_type=""
        col_constraint=""
        for i in "${!column_names[@]}"; do
            if [[ "${column_names[$i]}" == "$col_name_to_update" ]]; then
                col_index=$i
                col_type=${column_types[$i]}
                col_constraint=${column_constraints[$i]}
                break
            fi
        done

        if [[ $col_index -eq -1 ]]; then
            dialog --msgbox "Column not found!" 10 40
            continue
        fi

        break
    done


    while true; do
        new_value=$(dialog --inputbox "Enter new value for $col_name_to_update:" 10 40 --output-fd 1)
        EXIT_STATUS=$?


        if [ $EXIT_STATUS -ne 0 ]; then
            dialog --msgbox "Returning to table menu..." 10 40
            return 1
        fi


        if [[ "$col_constraint" == "primaryKey" ]]; then
            if [[ -z "$new_value" ]]; then
                dialog --msgbox "Primary key value cannot be empty!" 10 40
                continue
            fi
            while IFS=: read -r -a row; do
                if [[ "${row[$col_index]}" == "$new_value" ]]; then
                    dialog --msgbox "Value must be unique!" 10 40
                    continue 2
                fi
            done < "$table_path"
        elif [[ "$col_constraint" == "unique" ]]; then
            if [[ -n "$new_value" ]]; then
                while IFS=: read -r -a row; do
                    if [[ "${row[$col_index]}" == "$new_value" ]]; then
                        dialog --msgbox "Value must be unique!" 10 40
                        continue 2
                    fi
                done < "$table_path"
            fi
        elif [[ "$col_constraint" == "notNull" ]]; then
            if [[ -z "$new_value" ]]; then
                dialog --msgbox "Value cannot be null!" 10 40
                continue
            fi
        fi


        if [[ -n "$new_value" ]]; then
            if [[ "$col_type" == "number" && ! "$new_value" =~ ^[0-9]+$ ]]; then
                dialog --msgbox "Invalid number format!" 10 40
                continue
            elif [[ "$col_type" == "string" && ! "$new_value" =~ ^[a-zA-Z]+$ ]]; then
                dialog --msgbox "Invalid string format!" 10 40
                continue
            elif [[ "$col_type" == "email" && ! "$new_value" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z.-]+\.[a-zA-Z]{2,}$ ]]; then
                dialog --msgbox "Invalid email format!" 10 40
                continue
            elif [[ "$col_type" == "date" && ! "$new_value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                dialog --msgbox "Invalid date format (YYYY-MM-DD)!" 10 40
                continue
            fi
        fi

        break
    done

    awk -v row_num="$row_to_update" -v col="$col_index" -v val="$new_value" -F: '
    NR == row_num {
        split($0, a, ":");
        a[col+1] = val;
        $0 = "";
        for (i = 1; i <= length(a); i++) {
            $0 = $0 (i>1 ? ":" : "") a[i]
        }
    }
    { print }
    ' "$table_path" > "$table_path".tmp && mv "$table_path".tmp "$table_path"

    dialog --msgbox "Record updated successfully!" 10 40
}