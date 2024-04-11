locals {
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y apache2 php libapache2-mod-php php-mysql mysql-server

    sudo systemctl start apache2
    sudo systemctl enable apache2 
    sudo systemctl start mysql
    sudo systemctl enable mysql

    # Create MySQL database and table
    sudo mysql -u root -e "CREATE DATABASE web;"
    sudo mysql -u root -e "USE web;"
    sudo mysql -u root -e "CREATE TABLE web.register (UserName VARCHAR(255), Password VARCHAR(255));"
    sudo mysql -u root -e "CREATE USER 'Mariana'@'localhost' IDENTIFIED BY '123';"
    sudo mysql -u root -e "GRANT ALL PRIVILEGES ON web.* TO 'Mariana'@'localhost';"
    sudo mysql -u root -e "FLUSH PRIVILEGES;"

    sudo rm /var/www/html/index.html
    # Create HTML form file
    sudo vim -e -s /var/www/html/index.html <<VIM_SCRIPT
    1i
    <!DOCTYPE html>
    <html>
    <head>
        <title>Form site</title>
        <style>
            form {
                padding-top: 120px;
                text-align: center;
                font-size: 30px;
            }
            input {
                width: 250px;
                height: 40px;
                font-size: 30px;
            }
        </style>
    </head>
    <body>
    <form method="post" action="index.php">
        Username : <input type="text" name="username"><br><br>
        Password : <input type="password" name="password"><br><br>
        <input type="submit" value="Submit">
    </form>
    </body>
    </html>
    .
    wq
    VIM_SCRIPT
 
    sudo vim -e -s /var/www/html/index.php <<VIM_SCRIPT
    1i
    <?php
        error_reporting(E_ALL);
        ini_set("display_errors", 1);
 
        \$username = filter_input(INPUT_POST, "username");
        \$password = filter_input(INPUT_POST, "password");
 
        if (!empty(\$username) && !empty(\$password)) {
            \$host = "localhost";
            \$dbusername = "Mariana";
            \$dbpassword = "123";
            \$dbname = "web";
 
            // Create connection
            \$conn = new mysqli(\$host, \$dbusername, \$dbpassword, \$dbname);
 
            // Check connection
            if (\$conn->connect_error) {
                die("Connect Error (" . mysqli_connect_errno() . ") " . mysqli_connect_error());
            }
 
            // Prepare SQL statement
            \$sql = "INSERT INTO register (UserName, Password) VALUES (?, ?)";
            \$stmt = \$conn->prepare(\$sql);
 
            if (\$stmt) {
                // Bind parameters and execute the statement
                \$stmt->bind_param("ss", \$username, \$password);
 
                if (\$stmt->execute()) {
                    echo "New record inserted successfully";
                } else {
                    echo "Error: " . \$sql . "<br>" . \$conn->error;
                }
 
                // Close statement
                \$stmt->close();
            } else {
                echo "Error preparing statement: " . \$conn->error;
            }
 
            // Close connection
            \$conn->close();
        } else {
            echo "Username and password should not be empty";
        }
    ?>
    .
    wq
    VIM_SCRIPT

    EOF
}