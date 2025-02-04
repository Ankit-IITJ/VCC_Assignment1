#!/bin/bash

# Update system packages
sudo apt update -y

# Install MySQL server
sudo apt install -y mysql-server

# Secure MySQL installation (automates the root password setup)
sudo mysql_secure_installation <<EOF

Y
Y
Y
Y
Y
EOF

# Start MySQL service
sudo systemctl start mysql

# Check MySQL service status
if ! sudo systemctl status mysql | grep "active (running)"; then
    echo "MySQL failed to start. Please check the logs for errors."
    exit 1
else
    echo "MySQL successfully started."

    # Create a test database and user (as per web service requirements)
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS mydb;"
    sudo mysql -e "CREATE USER IF NOT EXISTS 'ankit'@'%' IDENTIFIED WITH mysql_native_password BY '12345';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON mydb.* TO 'ankit'@'%';"
    sudo mysql -e "FLUSH PRIVILEGES;"

    # Create a table and insert dummy data
    sudo mysql mydb -e "CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), email VARCHAR(100), age INT);"
    sudo mysql mydb -e "INSERT INTO users (name, email, age) VALUES ('Ankit Chauhan', 'm23csa509@iitj.ac.in', 34);"

    # Allow MySQL to accept connections from all IPs
    sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

    # Restart MySQL to apply configuration changes
    sudo systemctl restart mysql

    # Check if MySQL service restarted successfully
    if sudo systemctl status mysql | grep "active (running)"; then
        echo "MySQL setup complete. User 'ankit' created and granted permissions."
    else
        echo "Failed to restart MySQL after configuration changes."
        exit 1
    fi
fi
