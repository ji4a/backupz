#!/bin/bash

WATCH_DIR="/var/www/onlyoffice/Data/Backupz"
ZIP_DIR="/var/www/onlyoffice/Data/Backupz/zip"

mkdir -p "$ZIP_DIR"

inotifywait -m -e create --format "%f" "$WATCH_DIR" | while read NEW_FILE
do
    if [[ "$NEW_FILE" =~ \.tar\.gz$ ]]; then
        ZIP_FILE="${NEW_FILE%.tar.gz}.zip"
        
        NEW_FILE_PATH="$WATCH_DIR/$NEW_FILE"
        ZIP_FILE_PATH="$WATCH_DIR/$ZIP_FILE"
        
        echo "Compressing $NEW_FILE_PATH to $ZIP_FILE_PATH..."
        zip -r "$ZIP_FILE_PATH" "$NEW_FILE_PATH"

        sleep 10
        
        mv "$ZIP_FILE_PATH" "$ZIP_DIR"
        echo "Moved $ZIP_FILE to $ZIP_DIR"
    fi
done
