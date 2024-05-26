#!/bin/bash

LOG_FILE="/home/lovepreet/Downloads/backup.log"

# Function to check if a directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo "Error: Directory $1 does not exist." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Function to compress the directory
compress_directory() {
    local dir_name="$1"
    local archive_name="${dir_name%/}.tar.gz"
    
    tar -czf "$archive_name" -C "$(dirname "$dir_name")" "$(basename "$dir_name")"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to compress the directory." | tee -a "$LOG_FILE"
        exit 1
    fi
    
    echo "Directory compressed to $archive_name" | tee -a "$LOG_FILE"
    echo "$archive_name"
}

# Function to upload the file using scp
upload_file() {
    local file_path="$1"
    local remote_host="$2"
    local port="$3"
    local remote_dir="$4"
    
    scp -P "$port" "$file_path" "$remote_host":"$remote_dir" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to upload the file." | tee -a "$LOG_FILE"
        exit 1
    fi
    
    echo "File uploaded successfully to $remote_host:$remote_dir" | tee -a "$LOG_FILE"
}

# Main script logic
main() {
    local directory="$1"

    # Prompt for directory if not provided as an argument
    if [ -z "$directory" ]; then
        read -p "Please enter the directory to backup: " directory
        echo "User provided directory: $directory" | tee -a "$LOG_FILE"
    else
        echo "Directory provided as argument: $directory" | tee -a "$LOG_FILE"
    fi

    # Check if the directory exists
    check_directory "$directory"

    # Prompt for remote server details
    read -p "Enter the IP address or URL of the remote server: " remote_host
    read -p "Enter the port number of the remote server: " port
    read -p "Enter the target directory on the remote server: " remote_dir

    echo "Remote server details: Host=$remote_host, Port=$port, Target directory=$remote_dir" | tee -a "$LOG_FILE"

    # Compress the directory
    archive=$(compress_directory "$directory")

    # Upload the compressed file
    upload_file "$archive" "$remote_host" "$port" "$remote_dir"

    # Cleanup the local archive file
    rm "$archive"
    echo "Local archive file $archive removed." | tee -a "$LOG_FILE"
}

# Execute the main function with the first argument passed to the script
main "$1"

