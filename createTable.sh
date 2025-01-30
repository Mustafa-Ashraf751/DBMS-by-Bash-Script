#!/bin/bash

create_table() {
DB_DIR="$1"
DB_Name="$2"
while true; do
  TB_Name=$(dialog --inputbox "please enter table name:" 10 40 --output-fd 1)
  EXIT_STATUS=$?

  if [ $EXIT_STATUS -ne 0 ]; then
  dialog --msgbox "Going back to table menu ..." 10 40
  return 1
  fi

  if [[ -z $TB_Name ]]; then
   dialog --msgbox "Table name cannot be empty!" 10 40
   continue
  elif [ -d "$DB_DIR/$DB_Name/$TB_Name" ]; then
  dialog --msgbox "Table already exists" 10 30
  continue
  elif [[ ! $TB_Name =~ ^[a-zA-Z_]+$ ]]; then    
  dialog --msgbox "Invalid table name please try again!" 10 40
  continue
  else 
  mkdir -p "$DB_DIR/$DB_Name/$TB_Name"
  touch "$DB_DIR/$DB_Name/$TB_Name/$TB_Name.csv"
  touch "$DB_DIR/$DB_Name/$TB_Name/$TB_Name.meta"
  num_cols=$(dialog --inputbox "Enter the number of columns:" 10 40 --output-fd 1)
  if [[ -z $num_cols ]]; then
    dialog --msgbox "Number of columns cannot be empty!" 10 40
    continue
  elif [[ ! $num_cols =~ ^[0-9]+$ ]]; then
    dialog --msgbox "Invalid number of columns!" 10 40
    continue
  fi
   primaryKey=0 # initialize primaryKey to 0
   tempCol="" # initialize tempCol  
   declare -a columns # initialize columns array to make sure that table has primary key
   for((i=1; i <= num_cols; i++)); do
      col_name=$(dialog --inputbox "Enter column name for col $i:" 10 40 --output-fd 1)
      if [[ -z $col_name ]]; then
        dialog --msgbox "Column name cannot be empty!" 10 40
        continue
      fi
      if [[ ! $col_name =~ ^[a-zA-Z_]+$ ]]; then
        dialog --msgbox "Invalid column name!" 10 40
        continue
      fi
      col_type=$(dialog --inputbox "Enter column type for col $i:" 10 40 --output-fd 1)
      if [[ -z $col_type ]]; then
        dialog --msgbox "Column type cannot be empty!" 10 40
        continue
      fi
      if [[ ! $col_type =~ ^[a-zA-Z0-9_()]+$ ]]; then
        dialog --msgbox "Invalid column type!" 10 40
        continue
      fi
      if [  $primaryKey -eq 0 ]; then
        while true; do
          check=$(dialog --inputbox "Do you want to make this column primary key for table $TB_Name (yes/no):" 10 40 --output-fd 1)
          if [[ $check == "yes" ]]; then
          primaryKey=1
          tempCol="$col_name:$col_type:primary"
          break
          elif [[ $check == "no" ]]; then
          tempCol="$col_name:$col_type"
          break
          else  
          dialog --msgbox "Invalid input please try again!" 10 40
          fi
        done
     else 
      tempCol="$col_name:$col_type"
     fi
     columns+=("$tempCol")
  done
  #Make sure that table has primary key
  if [ $primaryKey -eq 0 ]; then
    dialog --msgbox "Table must have a primary key" 10 30
    continue
  fi
  printf "%s\n" "${columns[@]}" > "$DB_DIR/$DB_Name/$TB_Name/$TB_Name.meta"  
  dialog --msgbox "Table created successfully" 10 25
  return 0
  fi  
done
}
