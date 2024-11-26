#!/bin/bash

#sudo apt update -y
#sudo apt install sshpass rsync inotify-tools curl -y

#### TRANSFER BACKUP FILE TO ANOTHER SERVER ####
### nohup transfer.sh &> transfer_log.log & ####

WATCH_DIR=""
REMOTE_USER="root"
REMOTE_HOST=""
REMOTE_DIR=""
PASSWORD=""
PORT="22"

TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""

send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d text="${message}" >/dev/null
}

inotifywait -m -e create -e moved_to --format "%f" "$WATCH_DIR" | while read -r NEW_FILE
do
    FILE_PATH="${WATCH_DIR}/${NEW_FILE}"

    if [[ -f "$FILE_PATH" ]]; then
        echo "File detected: $NEW_FILE. Uploading to $REMOTE_HOST..."
        send_telegram_message "Backup: ${NEW_FILE} is uploading now.. one moment please.."

        sshpass -p "$PASSWORD" rsync -e "ssh -p $PORT" --progress "$FILE_PATH" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

        if [[ $? -eq 0 ]]; then
            echo "Successfully uploaded: $NEW_FILE"
            send_telegram_message "Backup: ${NEW_FILE} is uploaded! Goodnight!"
        
        sleep 3
        
        rm "$FILE_PATH"
            echo "File deleted from server: $NEW_FILE"    

        else
            echo "Failed to upload: $NEW_FILE"
            send_telegram_message "Failed to upload: ${NEW_FILE}. Please check the server."
        fi
    fi
done
