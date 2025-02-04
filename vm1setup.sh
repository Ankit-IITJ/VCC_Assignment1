#!/bin/bash

# Exit script if any command fails
set -e

# Update and install lighttpd
echo "Updating package list and installing lighttpd..."
sudo apt update
sudo apt install -y lighttpd

# Start and enable the lighttpd service
echo "Starting and enabling lighttpd service..."
sudo systemctl start lighttpd
sudo systemctl enable lighttpd

# Create the index.html file in /var/www/html/
HTML_PATH="/var/www/html/index.html"
echo "Creating index.html in /var/www/html/..."
sudo bash -c "cat > $HTML_PATH" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #eaeff1;
            color: #444;
        }

        h1 {
            text-align: center;
            margin: 0;
            padding: 15px;
            background-color: #5c6bc0;
            color: white;
            font-size: 28px;
        }

        .container {
            max-width: 900px;
            margin: 20px auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            padding: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: left;
        }

        th {
            background-color: #5c6bc0;
            color: white;
        }

        button {
            padding: 10px;
            margin: 5px 0;
            width: 100%;
            border: none;
            border-radius: 4px;
            background-color: #5c6bc0;
            color: white;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        button:hover {
            background-color: #4959b3;
        }

        .actions button {
            margin-right: 5px;
            padding: 5px 10px;
        }

        .empty-row {
            text-align: center;
            color: #999;
        }

        /* Modal styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
        }

        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 20px;
            border-radius: 10px;
            width: 50%;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        .modal-content h2 {
            margin-top: 0;
            font-size: 22px;
            color: #444;
        }

        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }

        .close:hover, .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }

        .modal-content input {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        .modal-content button {
            width: auto;
            margin-top: 10px;
        }

        .modal-content label {
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h1>User Management</h1>
    <div class="container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Age</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="usersTable">
                <!-- Dynamic rows will be inserted here -->
            </tbody>
        </table>
        <button onclick="openAddModal()">Add New User</button>
    </div>

    <!-- Modal for adding/editing a user -->
    <div id="userModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2 id="modalTitle">Add New User</h2>
            <form id="userForm">
                <label for="modalName">Name</label>
                <input type="text" id="modalName" placeholder="Name" required>
                <label for="modalEmail">Email</label>
                <input type="email" id="modalEmail" placeholder="Email" required>
                <label for="modalAge">Age</label>
                <input type="number" id="modalAge" placeholder="Age" required>
                <button type="button" id="modalSubmitButton" onclick="handleUserAction()">Submit</button>
            </form>
        </div>
    </div>

    <script>
        const API_URL = "http://192.168.29.132:3000/users";
        let isEditMode = false;
        let editingUserId = null;

        function fetchUsers() {
            fetch(API_URL)
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`Error: ${response.status} ${response.statusText}`);
                    }
                    return response.json();
                })
                .then(users => {
                    const table = document.getElementById("usersTable");
                    table.innerHTML = "";

                    if (users.length === 0) {
                        table.innerHTML = `
                            <tr>
                                <td colspan="5" class="empty-row">No records found</td>
                            </tr>
                        `;
                    } else {
                        users.forEach(user => {
                            const row = `
                                <tr>
                                    <td>${user.id}</td>
                                    <td>${user.name}</td>
                                    <td>${user.email}</td>
                                    <td>${user.age}</td>
                                    <td class="actions">
                                        <button onclick="openEditModal(${user.id}, '${user.name}', '${user.email}', ${user.age})">Edit</button>
                                        <button onclick="deleteUser(${user.id})">Delete</button>
                                    </td>
                                </tr>
                            `;
                            table.innerHTML += row;
                        });
                    }
                })
                .catch(error => {
                    console.error(error);
                    alert("Failed to fetch users. Please try again later.");
                });
        }

        function openAddModal() {
            isEditMode = false;
            editingUserId = null;
            document.getElementById("modalTitle").textContent = "Add New User";
            document.getElementById("modalName").value = "";
            document.getElementById("modalEmail").value = "";
            document.getElementById("modalAge").value = "";
            document.getElementById("userModal").style.display = "block";
        }

        function openEditModal(id, name, email, age) {
            isEditMode = true;
            editingUserId = id;
            document.getElementById("modalTitle").textContent = "Edit User";
            document.getElementById("modalName").value = name;
            document.getElementById("modalEmail").value = email;
            document.getElementById("modalAge").value = age;
            document.getElementById("userModal").style.display = "block";
        }

        function closeModal() {
            document.getElementById("userModal").style.display = "none";
        }

        function handleUserAction() {
            const name = document.getElementById("modalName").value;
            const email = document.getElementById("modalEmail").value;
            const age = document.getElementById("modalAge").value;

            if (isEditMode) {
                updateUser(editingUserId, { name, email, age });
            } else {
                addUser({ name, email, age });
            }
        }

        function addUser(user) {
            fetch(API_URL, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(user)
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`Error: ${response.status} ${response.statusText}`);
                    }
                    return response.json();
                })
                .then(() => {
                    alert("User added successfully!");
                    closeModal();
                    fetchUsers();
                })
                .catch(error => {
                    console.error(error);
                    alert("Failed to add user. Please try again.");
                });
        }

        function updateUser(id, user) {
            fetch(`${API_URL}/${id}`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(user)
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`Error: ${response.status} ${response.statusText}`);
                    }
                    return response.json();
                })
                .then(() => {
                    alert("User updated successfully!");
                    closeModal();
                    fetchUsers();
                })
                .catch(error => {
                    console.error(error);
                    alert("Failed to update user. Please try again.");
                });
        }

        function deleteUser(id) {
            if (confirm("Are you sure you want to delete this user?")) {
                fetch(`${API_URL}/${id}`, {
                    method: "DELETE"
                })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`Error: ${response.status} ${response.statusText}`);
                        }
                        alert("User deleted successfully!");
                        fetchUsers();
                    })
                    .catch(error => {
                        console.error(error);
                        alert("Failed to delete user. Please try again.");
                    });
            }
        }

        fetchUsers();
    </script>
</body>
</html>
EOF

# Set appropriate permissions for /var/www/html/index.html
echo "Setting permissions for index.html..."
sudo chmod 644 $HTML_PATH
sudo chown www-data:www-data $HTML_PATH

# Restart lighttpd to apply changes
echo "Restarting lighttpd service..."
sudo systemctl restart lighttpd

echo "Setup complete."
