#!/bin/bash

# Exit on error
set -e

# Update and install necessary packages
echo "Updating system packages..."
sudo apt update

# Install Node.js (LTS version) and npm
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js and npm installation
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

# Install MySQL client
echo "Installing MySQL client..."
sudo apt install -y mysql-client

# Set up project directory
PROJECT_DIR="node_web_service"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Creating project directory..."
    mkdir "$PROJECT_DIR"
fi
cd "$PROJECT_DIR"

# Create package.json if it doesn't exist
if [ ! -f "package.json" ]; then
    echo "Initializing npm..."
    npm init -y
fi

# Install project dependencies
echo "Installing project dependencies..."
npm install express mysql body-parser cors

# Save the web service code to a file
SERVICE_FILE="index.js"
cat <<'EOF' > $SERVICE_FILE
const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(cors({
    origin: "http://192.168.29.131",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type"]
}));

// Middleware
app.use(bodyParser.json());

// MySQL Connection
const db = mysql.createConnection({
    host: '192.168.29.133',
    user: 'ankit',
    password: '12345',
    database: 'mydb'
});

// Connect to MySQL
db.connect((err) => {
    if (err) {
        console.error('Error connecting to the database:', err);
    } else {
        console.log('Connected to the MySQL database');
    }
});

// Routes

// Create a new user
app.post('/users', (req, res) => {
    const { name, email, age } = req.body;
    const query = 'INSERT INTO users (name, email, age) VALUES (?, ?, ?)';
    db.query(query, [name, email, age], (err, result) => {
        if (err) {
            console.error('Error inserting user:', err);
            res.status(500).send('Database error');
        } else {
            res.status(201).send({ id: result.insertId, name, email, age });
        }
    });
});

// Get all users
app.get('/users', (req, res) => {
    const query = 'SELECT * FROM users';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching users:', err);
            res.status(500).send('Database error');
        } else {
            res.status(200).send(results);
        }
    });
});

// Get a single user by ID
app.get('/users/:id', (req, res) => {
    const { id } = req.params;
    const query = 'SELECT * FROM users WHERE id = ?';
    db.query(query, [id], (err, results) => {
        if (err) {
            console.error('Error fetching user:', err);
            res.status(500).send('Database error');
        } else if (results.length === 0) {
            res.status(404).send('User not found');
        } else {
            res.status(200).send(results[0]);
        }
    });
});

// Update a user by ID
app.put('/users/:id', (req, res) => {
    const { id } = req.params;
    const { name, email, age } = req.body;
    const query = 'UPDATE users SET name = ?, email = ?, age = ? WHERE id = ?';
    db.query(query, [name, email, age, id], (err, result) => {
        if (err) {
            console.error('Error updating user:', err);
            res.status(500).send('Database error');
        } else if (result.affectedRows === 0) {
            res.status(404).send('User not found');
        } else {
            res.status(200).send({ id, name, email, age });
        }
    });
});

// Delete a user by ID
app.delete('/users/:id', (req, res) => {
    const { id } = req.params;
    const query = 'DELETE FROM users WHERE id = ?';
    db.query(query, [id], (err, result) => {
        if (err) {
            console.error('Error deleting user:', err);
            res.status(500).send('Database error');
        } else if (result.affectedRows === 0) {
            res.status(404).send('User not found');
        } else {
            res.status(200).send({ message: 'User deleted successfully' });
        }
    });
});

// Start the server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
EOF

# Run the web service
echo "Starting the web service..."
node $SERVICE_FILE
