#!/bin/bash

insert_into_table() {
  DB_DIR="$1"
  DB_Name="$2"
 
  while true; do
   table_name=$(dialog --inputbox "Enter the name of table to insert into:" 10 40 --output-fd 1)
   EXIST_STATUS=$?
   if [ $EXIST_STATUS -ne 0 ]; then
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

    if [ ! -d "$DB_DIR/$DB_Name/$table_name" ]; then
       dialog --msgbox "Table does not exist!" 10 40
       continue
    fi
    break
 done
  metaDataFile="$DB_DIR/$DB_Name/$table_name/$table_name.meta"
  dataFile="$DB_DIR/$DB_Name/$table_name/$table_name.csv"

  #Initialize the row to store the data
  row=""

while read -r line; do
 while true; do
  colName=$(echo "$line" | awk -F':' '{print $1}')
  datatype=$(echo "$line" | awk -F':' '{print $2}')
  colConstraint=$(echo "$line" | awk -F':' '{print $3}')

  colValue=$(dialog --inputbox "Please enter valid value for col $colName for data type: $datatype" 10 50 --output-fd 1)
  
  case $colConstraint in
  primaryKey)
             
             if [[ -z $colValue ]]; then
                   dialog --msgbox "The value cannot be null!" 10 40
                   continue
              fi

             checkForDuplication "$metaDataFile" "primaryKey" "$colValue" "$dataFile"
             EXIST_STATUS=$?
             if [ $EXIST_STATUS -ne 0 ]; then
                dialog --msgbox "Primary key should be unique!" 10 40
                continue
             fi  
             
             check_data_type "$datatype" "$colValue"
              EXIST_STATUS=$?
              if [ $EXIST_STATUS -ne 0 ]; then
                continue
              fi


                 row+="$colValue:"
         
  ;;
  notNull)
              if [[ -z $colValue ]]; then
                   dialog --msgbox "The value cannot be null!" 10 40
                   continue
              fi

              check_data_type "$datatype" "$colValue"
              EXIST_STATUS=$?
              if [ $EXIST_STATUS -ne 0 ]; then
                continue
              fi
              row+="$colValue:"
  ;;
  unique)
    
            if [[ -z $colValue ]]; then
                   dialog --msgbox "The value cannot be null!" 10 40
                   continue
              fi

             checkForDuplication "$metaDataFile" "unique" "$colValue" "$dataFile"
             if [ $? -ne 0 ]; then
                dialog --msgbox "This value is already in the table please try another one"
                continue
             fi  

             check_data_type "$datatype" "$colValue" 
              EXIST_STATUS=$?
              if [ $EXIST_STATUS -ne 0 ]; then
                continue
              fi
               
              row+="$colValue:"
                 

  ;;
  none)

              check_data_type "$datatype" "$colValue"
              EXIST_STATUS=$?
              if [ $EXIST_STATUS -ne 0 ]; then
                continue
              fi
              row+="$colValue:"
  ;;
  esac
  break
 done    
done < "$metaDataFile"
   
    printf "%s\n" "${row%:}" >> "$dataFile"
    dialog --msgbox "Record inserted successfully!" 10 40

}

get_column_number(){

  constraint=$2
  awk -v constrain=$constraint -F: '{
  if($3 == constrain) print NR
  }' "$1";
}

checkForDuplication(){
 newValue=$3
 colid=$(get_column_number "$1" "$2")
 awk -F: -v newval="$newValue" -v columnId=$colid '{
    if($columnId == newval) exit 1
 }' "$4";

 return $?
}

check_data_type(){
  datatype=$1
  value=$2
   case $datatype in
          string)
              
                  if [[ ! $value =~ ^[a-zA-Z_]+$ ]]; then
                       dialog --msgbox "Invalid input for data type string!" 10 40
                       return 1
                  fi
          ;;
          number)
                   if [[ ! $value =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                      dialog --msgbox "Invalid input for data type number!" 10 40
                       return 1
                   fi  
          ;;
          email)
                  if [[ ! $value =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                      dialog --msgbox "Invalid input for data type email!" 10 40
                       return 1
                  fi     
          ;;
          date)  
                  if [[ ! $value =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                      dialog --msgbox "Invalid input for data type date!" 10 40
                       return 1
                  fi
          ;;
    esac
  return 0
}