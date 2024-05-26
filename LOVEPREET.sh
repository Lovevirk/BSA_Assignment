#!/bin/bash

# Function to print errors to console and log file
print_error() {
    local message="$1"
    echo "Error: $message"
    echo "$(date): Error: $message" >> script.log
}

# Function to print informational messages to console and log file
print_info() {
    local message="$1"
    echo "$message"
    echo "$(date): $message" >> script.log
}

# Function to create user
create_user() {
    local username="$1"
    local password="$2"

    # Check if user already exists
    if id "$username" &>/dev/null; then
        print_info "User $username already exists. Skipping user creation."
        return
    fi

    # Create user with default password
    sudo useradd -m -s /bin/bash "$username"
    echo "$username:$password" | sudo chpasswd

    # Enforce password change at first login
    sudo chage -d 0 "$username" || print_error "Failed to enforce password change for user $username"
}

# Function to create shared folder
create_shared_folder() {
    local folder_path="$1"

    # Check if folder already exists
    if [ -d "$folder_path" ]; then
        print_info "Shared folder $folder_path already exists. Skipping folder creation."
        return
    fi

    # Create shared folder
    sudo mkdir -p "$folder_path"
    sudo chmod -R 777 "$folder_path" || print_error "Failed to set permissions for folder $folder_path"
}

# Function to create shared folder group
create_shared_folder_group() {
    local group_name="$1"

    # Trim whitespace from group name
    local trimmed_group_name="$(echo -e "$group_name" | tr -d '[:space:]')"

    # Check if group already exists
    if grep -q "^$trimmed_group_name:" /etc/group; then
        print_info "Group $trimmed_group_name already exists. Skipping group creation."
    else
        # Create shared folder group
        sudo groupadd "$trimmed_group_name" || print_error "Failed to create group $trimmed_group_name"
        print_info "Group $trimmed_group_name created."
    fi
}

# Function to add user to specified groups
add_user_to_groups() {
    local username="$1"
    local groups="$2"

    # If no groups are specified, return
    if [ -z "$groups" ]; then
        echo "No groups specified. User $username not added to any group."
        return
    fi

    # Strip leading and trailing quotation marks from groups
    groups=$(echo "$groups" | sed 's/^"\|"$//g')

    # Split groups by comma into an array
    IFS=',' read -ra group_list <<< "$groups"

    # Add user to each group
    for group in "${group_list[@]}"; do
        # Print the group name being processed
        echo "Processing group: $group"

        # Check if the group exists
        if grep -q "^$group:" /etc/group; then
            sudo usermod -aG "$group" "$username" && print_info "User $username added to group $group."
        else
            # If the group doesn't exist, create it and then add the user
            sudo groupadd "$group" && print_info "Group $group created."
            sudo usermod -aG "$group" "$username" && print_info "User $username added to group $group."
        fi
    done
}




# Function to create link to shared folder in user's home directory
create_shared_folder_link() {
    local username="$1"
    local folder_path="$2"
    local link_path="/home/$username/shared"

    # Check if symbolic link already exists
    if [ -L "$link_path" ]; then
        print_info "Symbolic link $link_path already exists. Skipping link creation."
        return
    fi

    # Create link in user's home directory
    sudo ln -s "$folder_path" "$link_path" || print_error "Failed to create link to shared folder for user $username"
}

# Function to create alias for sudo users
create_sudo_alias() {
    local username="$1"

    # Check if user is in sudo group
    if id -nG "$username" | grep -q '\bsudo\b'; then
        # Add alias for myls to show hidden files and permissions in home directory
        echo "alias myls='ls -la'" | sudo tee -a "/home/$username/.bash_aliases" > /dev/null || print_error "Failed to create alias for user $username"
    fi
}

# Function to parse CSV file and process user data
process_csv_file() {
    local csv_file="$1"

    # Check if CSV file exists
    if [ ! -f "$csv_file" ]; then
        print_error "CSV file $csv_file does not exist."
        exit 1
    fi

    # Read CSV file line by line, skipping the header
    tail -n +2 "$csv_file" | while IFS=';' read -r email birth_date groups shared_folder; do
        # Extract username from email address
        username=$(echo "$email" | cut -d '@' -f 1)

        # Generate default password from birth date
        password=$(date -d "$birth_date" "+%m%Y")

        # Ensure password length is at least 8 characters
        if [ ${#password} -lt 8 ]; then
            # Append additional characters to meet the minimum length requirement
            password="$password"'!Aa1'
        fi

        # Create user
        create_user "$username" "$password"

        # Create shared folder group if provided
        if [ -n "$shared_folder" ]; then
            create_shared_folder_group "$shared_folder"
            create_shared_folder "$shared_folder"
            create_shared_folder_link "$username" "$shared_folder"
        fi

        # Add user to specified groups
        add_user_to_groups "$username" "$groups"

        # Create alias for sudo users
        create_sudo_alias "$username"

        # Print summary of user environment
        print_info "User $username created with password $password."
    done
}

# Main function
main() {
    # Check if script is run as root
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root." >&2
        exit 1
    fi

    # Check if at least one command line argument is provided
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <csv_file>" >&2
        exit 1
    fi

    local csv_file="$1"

    # Check for existence of log file and create if not exists
    if [ ! -f "script.log" ]; then
        touch script.log || { echo "Failed to create log file." >&2; exit 1; }
    fi

    # Print script start message to console and log file
    print_info "Starting script..."

    # Process CSV file
    process_csv_file "$csv_file"

    # Print script end message to console and log file
    print_info "Script completed."
}

# Call main function with command line arguments
main "$@"

