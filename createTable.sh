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
    EXIT_STATUS=$?
    if [ $EXIT_STATUS -ne 0 ]; then
    rm -r "$DB_DIR/$DB_Name/$TB_Name"
    dialog --msgbox "Going back to table menu ..." 10 40
    return 1
    fi
  if [[ -z $num_cols ]]; then
    dialog --msgbox "Number of columns cannot be empty!" 10 40
    rm -r "$DB_DIR/$DB_Name/$TB_Name"
    continue
  elif [[ ! $num_cols =~ ^[0-9]+$ ]]; then
    dialog --msgbox "Invalid number of columns!" 10 40
    rm -r "$DB_DIR/$DB_Name/$TB_Name"
    continue
  fi
   validTable=1
   primaryKey=0 # initialize primaryKey to 0
   tempCol="" # initialize tempCol  
   declare -a columns # initialize columns array to make sure that table has primary key
   for((i=1; i <= num_cols; i++)); do
      col_name=$(dialog --inputbox "Enter column name for col $i:" 10 40 --output-fd 1)
      EXIT_STATUS=$?
      if [ $EXIT_STATUS -ne 0 ]; then
      rm -r "$DB_DIR/$DB_Name/$TB_Name"
      dialog --msgbox "Going back to table menu ..." 10 40
      return 1
      fi
      if [[ -z $col_name ]]; then
        dialog --msgbox "Column name cannot be empty!" 10 40
        validTable=0
        rm -r "$DB_DIR/$DB_Name/$TB_Name"
        break
      fi
      if [[ ! $col_name =~ ^[a-zA-Z_]+$ ]]; then
        dialog --msgbox "Invalid column name!" 10 40
        validTable=0
        rm -r "$DB_DIR/$DB_Name/$TB_Name"
        break
      fi
      #let the user choose the data type
      choice=$(dialog --title "Please choose data type of table  $TB_Name" --menu "choose an option:" 15 50 6 \1 "String" \
      2 "Number" \
      3 "Email"  \
      4 "Date" --output-fd 1)
      EXIT_STATUS=$?

      if [ $EXIT_STATUS -ne 0 ]; then 
      dialog --msgbox "Going back to table menu ..." 10 40
      rm -r "$DB_DIR/$DB_Name/$TB_Name"
      return 1
      fi
     
     case $choice in 
      1) col_type=string;;
      2) col_type=number;;
      3) col_type=email;;
      4) col_type=date;;
      esac

      EXIT_STATUS=$?
      if [ $EXIT_STATUS -ne 0 ]; then 
      rm -r "$DB_DIR/$DB_Name/$TB_Name"
          dialog --msgbox "Going back to table menu ..." 10 40
          return 1
      fi
      #let the user choose the constraints
      

      if [ $primaryKey -eq 1 ]; then
        
        choice=$(dialog --title "Please choose data type of table  $TB_Name" --menu "choose an option:" 15 55 6 \1 "Not Null" \
         2 "Unique"  \
         3 "None" --output-fd 1)
         
         EXIT_STATUS=$?
         if [ $EXIT_STATUS -ne 0 ]; then 
             dialog --msgbox "Going back to table menu ..." 10 40
             rm -r "$DB_DIR/$DB_Name/$TB_Name"
              return 1
         fi
        
         case $choice in 
          1) col_constraint=notNull;;
          2) col_constraint=unique;;
          3) col_constraint=none;;
         esac
        else
         choice=$(dialog --title "Please choose data type of table  $TB_Name" --menu "choose an option:" 15 55 6 \1 "Primary Key (must choose at least one column)" \
         2 "Not Null" \
         3 "Unique"  \
         4 "None" --output-fd 1)

         EXIT_STATUS=$?
         if [ $EXIT_STATUS -ne 0 ]; then 
             dialog --msgbox "Going back to table menu ..." 10 40
             rm -r "$DB_DIR/$DB_Name/$TB_Name"
              return 1
         fi
         case $choice in 
          1) col_constraint=primaryKey
           primaryKey=1;;
          2) col_constraint=notNull;;
          3) col_constraint=unique;;
          4) col_constraint=none;;
         esac
      fi

      tempCol="$col_name:$col_type:$col_constraint"

      columns+=("$tempCol")
  done 
  if [ $validTable -eq 0 ]; then
  dialog --msgbox "Table is not created!" 10 30
  break
  fi
  #Make sure that table has primary key
  if [ $primaryKey -eq 0 ]; then
    dialog --msgbox "Table must have a primary key" 10 30
    rm -r "$DB_DIR/$DB_Name/$TB_Name"
    continue
  fi
  printf "%s\n" "${columns[@]}" > "$DB_DIR/$DB_Name/$TB_Name/$TB_Name.meta"  
  dialog --msgbox "Table created successfully" 10 25
  return 0
  fi  
done
}
