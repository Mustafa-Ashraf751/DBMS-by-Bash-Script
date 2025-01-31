#!/bin/bash

list_databases() {
    db_list=$(ls "$DB_DIR" 2>/dev/null)
    dialog --msgbox "Databases:\n$db_list" 15 40
}