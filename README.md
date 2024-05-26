# Bash Scripting Assignment (30% OF FINAL MARKS)
IA616001 OPERATING SYSTEM
SUBMITTED TO: WILLIAM

## Author Details
- **Full Name**: LOVEPRRET SINGH
- **Student Code (Login Name)**: 1000117287
- **DUE DATE**:26/05/2024

## Project Description
This repository contains two main Bash scripts developed for the IN616001 Operating Systems Concepts course at Otago Polytechnic. The scripts automate administrative tasks on an Ubuntu Linux server.

### Task 1: Creating a User Environment
The first script automates the creation of user accounts and configures their environments based on data provided in a CSV file.

#### INSTRUCTIONS :
1. OPEN TERMINAL:
2. CREATE A FILE WHERE YOU WANT TO WRITE THE SCRIPT.
3. MAKE SURE YOU HAVE THE CSV FILE GENERATED FROM THE OFFICE. IN CASE YOU DONT'T HAVE GO TO SAVE AS CHANGE THE FORMAT TO CSV
(IN MY SCRIPT THE PATH IS HARDCORED IF YOU WANT TO RUN YOURS ONE YOU NEED TO MODIFY THE SCRIPT.)
4. AFTER FOLLOWING ALL THE COMMANDS LIKE CHMOD +X AND./DIRECTORY, YOU WILL BE ASKED A QUE IF YOU WANT TO CREATE THE USER IF TYPED YES IT WILL BE ACCOMPLISHED.
5. YOU CAN VIEW ALL THE INFORMATION INSIDE THE USER_CREATION LOG WHICH WILL BE CREATED WHERE THE SCRIPT IS.

### Task 2: Backup Script
The second script compresses a specified directory and uploads the backup to a remote server. As well as it create a backup in the same remote location inside this machine.

#### INSTRUCTIONS :
1. OPEN TERMINAL.
2. CREATE A FILE WHERE YOU WANT TO WRITE THE SCRIPT. (NANO COMMAND AFTER WRITING THE SCRIPT PRESS CTRL+X THEN ENTER)
3. THE PATH IS NOT HARDCODED YOU CAN DO PUT YOUR LOCATION AS WELL BUT THERE IS A STRUCTURE YOU NEED TO FOLLOW <directory_to_backup> <remote_user> <remote_host> <remote_port> <remote_path> <output_directory>"

/home/lovepreet
## Prerequisites
- Ubuntu Linux system
- Bash shell
- `scp` command for remote file transfer
- Git (for version control)
- CSV file containing user data for Task 1

## Project Structure

├── README.md
├── BSA_Self_Assessment.txt
├── Task1
│ ├── LOVEPREET.sh
│ ├── USERS.csv
│ └── logs
└── Task2
├── BACKUP.sh
└── testdir
