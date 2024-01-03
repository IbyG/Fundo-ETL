#!/bin/bash

# Specify the directory containing the zip files
source_dir="/home/homelab/Network Shared/Fundo/ZipFiles/"
#specify the directory which the latest log files will be stored
extract_dir="/home/homelab/Network Shared/Fundo/LogExtracts/"
#file to store the zip file names that have been processed
processed_file="/home/homelab/Network Shared/Fundo/processed_files.txt"

# Flag to check if the first occurrence of GPSPointDetail has been processed as the line gets diplicated multiple times in the log file
processed=false


# Extract only the date portion
formatted_date=$(date -d "$date_part" "+%d-%m-%Y")

# Database connection information
db_name="Fundo"
Main_table="Main"
Sport_table="Sport"
heartRate_table="HeartRate"
myConf="/home/homelab/Scripts/Fundo-ETL/my.cnf"

# Function to process a line and insert data into the MariaDB table
process_line() {
    local line="$1"
    local record_type="$2"

    # Check if the line matches the specified pattern
    if [[ $line =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+) ]]; then
        # Extract relevant data from the matched line
        date_part="${BASH_REMATCH[1]}"

        # Check if the line contains the specified record type
        if [[ $line =~ bracel\ $record_type\ =([0-9.]+) ]]; then
            # Extract additional relevant data
            value="${BASH_REMATCH[1]}"

            echo "The date: $formatted_date"
            echo "The time: ${date_part:11}"  # Extracting the time from the date_part
            echo "The value: $value"

            # Convert date format to dd-mm-yyyy
            formatted_date=$(date -d "$date_part" "+%d-%m-%Y")

            # Insert data into the MariaDB table
            result=$(mysql --defaults-extra-file=$myConf -D "$db_name" -se "INSERT INTO $Main_table (Date, Time, Record_type, Value) VALUES (STR_TO_DATE('$formatted_date','%d-%m-%Y'), '${date_part:11}', '$record_type', '$value');")



            # Check the result
            if [ $? -eq 0 ]; then
                echo "Data inserted successfully."
            else
                echo "Error: Failed to insert data. MySQL error: $result"
            fi
        else
            echo "Error: Line does not contain the specified record type."
        fi
    else
        echo "Error: Line does not match the date pattern."
    fi
}


# Check if the source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory not found: $source_dir"
    exit 1
fi


# Create the processed files list if it doesn't exist
touch "$processed_file"

# Loop through each file in the directory
for file in "$source_dir"/*; do
    # Check if it's a file and ends with ".zip"
    if [ -f "$file" ] && [[ "$file" == *.zip ]]; then
        # Check if the file has already been processed
        if grep -q "$file" "$processed_file"; then
            echo "Skipping $file. Already processed."
        else
            # Extract the date from the zip file name using awk
            date_str=$(basename "$file" | sed -E 's/.*([0-9]{8}).*/\1/')
            date_str_us_format=$(basename "$file" | sed -E 's/.*([0-9]{4})([0-9]{2})([0-9]{2}).*/\1-\2-\3/')

            


            # Convert the date format (assuming it's in YYYYMMDD format)
            formatted_date=$(date -d "$date_str" "+%d-%m-%Y")
            echo "the Date is: " $formatted_date

            # Extract files from the zip archive
            unzip "$file" -d "$extract_dir"

            # Rename the log files to have the format "formatted_date Log.log"
            find "$extract_dir" -type f -name "*.log" -exec mv {} "$extract_dir/${formatted_date}.log" \;


            # Record the processed file in the list
            echo "$file" >> "$processed_file"

            echo "Extraction complete for: $file. Files are in the '$extract_dir' directory."
            #getting the log file name
            log_file=("$extract_dir${formatted_date}.log")
            echo "The file PWD: " $log_file
            #giving read permissions
            chmod a+r "$log_file"


            #section to remove all the rows that are not needed using the SED command
            #sed -i '/ /d' "$filename"
            #removing the first 44 lines
            sed -i '1,44d' "$log_file"

            #some random stuff
            sed -i '/at android.os/d' "$log_file"
            sed -i '/at com.kct.bluetooth.conn.Conn$5.run(Conn.java:450)/d' "$log_file"
            sed -i '/at android.app.ActivityThread.main(ActivityThread.java:8669)/d' "$log_file"
            sed -i '/at java.lang.reflect.Method.invoke(Native Method)/d' "$log_file"
            sed -i '/classNamecom.android.music.activitymanagement.TopLevelActivitypackageNamecom.google.android.music/d' "$log_file"
            #to do with connection extablishment
            sed -i '/V/d' "$log_file"
            #Watch Battery percentage
            sed -i '/I/d' "$log_file"
            # connection checks 
            #reson i dont just do 'D/' is because  'E/History' also gets deleted removing all the sport progress.
            sed -i '/D\/\[FunDoSDK\]/d' "$log_file"
            sed -i '/D/MainService:/d' "$log_file"
            sed -i '/D\/SystemUtils:/d' "$log_file"
            sed -i '/D\/weatherShow:/d' "$log_file"
            sed -i '/D\/lq3:/d' "$log_file"

            #
            sed -i '/W\/\[FunDoSDK\]:/d' "$log_file"
            #
            sed -i '/inService:\/d/d' "$log_file"
            #
            sed -i '/D\/MainService:/d' "$log_file"
            #some chinese stuff about 'sedentry'
            sed -i '/久坐开关/d' "$log_file"
            sed -i '/久坐开始时间/d' "$log_file"
            sed -i '/久坐结束时间/d' "$log_file"
            sed -i '/久坐重复/d' "$log_file"
            sed -i '/久坐时间/d' "$log_file"
            sed -i '/久坐阈值/d' "$log_file"

            #weather
            sed -i '/W/d' "$log_file"

            #
            sed -i '/E\/HomeFragment:/d' "$log_file"
            sed -i '/E\/liuxiaodata:/d' "$log_file"
            sed -i '/E\/开始定位:/d' "$log_file"
            sed -i '/binTime/d' "$log_file"


            #Here i need to go through each row of the file and insert the date from the log file into the fundomdb maria database
            # Loop through each line in the log file
            while IFS= read -r line; do
                #echo "The Line: $line"

                # Check if the line matches any of the specified patterns
                if [[ $line =~ bracel\ run\ =([0-9]+) ]]; then
                    process_line "$line" "run"
                elif [[ $line =~ bracel\ calorie\ =([0-9.]+) ]]; then
                    process_line "$line" "calorie"
                elif [[ $line =~ bracel\ distance\ =([0-9.]+) ]]; then
                    process_line "$line" "distance"
                fi

                #Here i am  processing the sport information
                count=0;
                # Loop through each data set
                while IFS=',' read -r data_group; do

                    ((count++))

                    if [ $count -eq 2 ] && [ "$processed" = "false" ]; then
                        echo "is it processed: " $processed
                        #assigning values to the variables
                        id=$(echo "$data_group" | grep -oP "id=\K\d+")
                        date=$(echo "$data_group" | grep -oP "date='[^']*'" | sed "s/date='\([^']\{10\}\).*/\1/")
                        #formatted_date=$(date -d "$date" "+%Y-%d-%m")
                        formatted_date=$(date -d "$date" "+%d-%m-%Y")
                        mile=$(echo "$data_group" | grep -oP "mile=\K[^,]+")
                        step=$(echo "$data_group" | grep -oP "step='\K[^']+")
                        min_heart_rate=$(echo "$data_group" | grep -oP "minHeartRate='\K[^']+")
                        max_heart_rate=$(echo "$data_group" | grep -oP "maxHeartRate='\K[^']+")
                        sport_time=$(echo "$data_group" | grep -oP "sportTime='\K[^']+")
                        arr_heart_rate=$(echo "$data_group" | grep -oP "arrheartRate='\K[^']+")
                        # Print the extracted information
                        echo "ID: $id"
                        echo "Date: $formatted_date"
                        echo "Mile: $mile"
                        echo "Step: $step"
                        echo "Min Heart Rate: $min_heart_rate"
                        echo "Max Heart Rate: $max_heart_rate"
                        echo "Sport Time: " $sport_time
                        echo "Heart Rate: " $arr_heart_rate
                        echo "---------------------"
                        
                        result=$(mysql --defaults-extra-file=$myConf -D "$db_name" -se "INSERT INTO $Sport_table (Sport_ID, KM_Mile, Date, Step, minHeartRate, maxHeartRate, sportTime) VALUES ('$id', '$mile', STR_TO_DATE('$formatted_date','%d-%m-%Y'), '$step', '$min_heart_rate', '$max_heart_rate', '$sport_time');")

                        #looping through each heart rate value and inserting it into the database
                        IFS='&' read -ra arr_heart_rate_values <<< "$arr_heart_rate"
			
			#as the data set has no seconds being captured we need to capture it in code
			seconds=0

                        # Loop through each value and print
                        for value in "${arr_heart_rate_values[@]}"; do
                            #echo "arrheartRate value: $value"
                            #inserting each heart rate value into the heart rate table
                            result=$(mysql --defaults-extra-file=$myConf -D "$db_name" -se "INSERT INTO $heartRate_table (Heart_Rate, Sport_ID,seconds) VALUES ($value, $id,$seconds);")
			    seconds=$((seconds + 10))
                        done

                        processed="true"
                        echo "Processed set to true, Processed value: " $processed

                    fi

                done <<< "$(echo "$line" | grep -oP "GpsPointDetailData\{[^}]*\}")"
               
               
            done < "$log_file"
            processed="false"
        fi
    fi
done

