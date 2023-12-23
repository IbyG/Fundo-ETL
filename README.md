# Fundo ETL Script

This script automates the extraction and transformation of log files from Fundo devices, inserting relevant data into a MariaDB database.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Notes](#notes)
- [License](#license)

## Prerequisites

Before using the script, ensure you have the following prerequisites installed:

- Bash shell
- MariaDB
- unzip utility

## Setup

1. **Clone the Repository:**

    ```bash
    git clone https://github.com/IbyG/Fundo-ETL.git
    ```

2. **Navigate to the Script Directory:**

    ```bash
    cd Fundo-ETL
    ```

3. **Set Up the Database Schema:**

    Run the following command to set up the database schema:

    ```bash
    mysql --defaults-extra-file=/path/to/your/my.cnf -D your_database < database_schema.sql
    ```

    Replace `/path/to/your/my.cnf` with the path to your `my.cnf` file, and `your_database` with the name of your MariaDB database.

4. **Create the `my.cnf` File:**

    Create a `my.cnf` file with database connection details:

    ```ini
    [client]
    host=192.192.192.192
    port=1111
    user=root
    password=toor
    ```

    Save the file in the script directory.
   
5. **Update Script**
   ```bash
    result=$(mysql --defaults-extra-file=/path/to/your/my.cnf -D "$db_name" -se "INSERT INTO $heartRate_table (Heart_Rate, Sport_ID) VALUES ($value, $id);")
    ```
   Update the path to the location where your `my.cnf` file is stored.
   
6. **Make the Script Executable:**

    ```bash
    chmod +x FundoExtractionScript.sh
    ```

7. **Run the Script:**

    ```bash
    ./FundoExtractionScript.sh
    ```

## Usage

- The script processes log files and inserts data into MariaDB tables.
- It skips files that have already been processed (tracked in `processed_files.txt`).
- Make sure to configure the database connection details in the script.

## Notes

- The database schema needs to be set up before executing the script. Use the `database_schema.sql` file for creating the necessary tables.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
