#!/bin/bash

while true
do

    CHOICE=$(dialog --title "Table Database menu" --menu "Choose an operation:" 15 50 7 \
    1 "Create Table" \
    2 "List Tables" \
    3 "Drop Table" \
    4 "Insert into Table" \
    5 "Select From Table" \
    6 "Delete From Table" \
    7 "Update Table" 3>&1 1>&2 2>&3)

    EXIT_STATUS=$?

    if [ $EXIT_STATUS -ne 0 ] 
    then 
       dialog --msgbox "Nice to meet you good bye" 10 25
       break
    fi   
 
    case $CHOICE in 
        1)
           #Call the function of create table
            RESULT="You choose option one!"
           ;;
        2)  #Call the function of list all tables
            RESULT="You choose option two!"
           ;;  
        3)  #Call the function of drop the table
            RESULT="You choose option three!"
           ;;
        4)  #Call the function of insert the table
            RESULT="You choose option four!"
           ;;      
        5)  #Call the function of select the table
            RESULT="You choose option five!"
           ;;      
        6) #call the function of delete the table
           RESULT="You choose option six"
           ;;
        7) #call the function of update the table
          RESULT="You choose option seven"
           ;;
    esac
    dialog --msgbox "$RESULT" 10 50
done       

      