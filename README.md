# Virtual Machine Network and Microservice Deployment

## Overview
This project demonstrates setting up multiple virtual machines (VMs) using VirtualBox, configuring a network between them, and deploying a microservice-based application across the connected VMs. It follows a three-tier architecture consisting of a web server, an API server, and a database server.

## Setup Steps
### 1. Install VirtualBox
- Download and install VirtualBox from [VirtualBox](https://www.virtualbox.org/).
- Create three virtual machines (VMs) with Lubuntu OS.

### 2. Create Virtual Machines
- **VM1 (Web Server)**: Hosts Lighttpd and serves frontend UI.
- **VM2 (API Server)**: Runs Node.js and Express.js for backend services.
- **VM3 (Database Server)**: Hosts MySQL database to store user records.

### 3. Configure Network
- Assign static IPs to all VMs.
- Configure network adapter as Bridged to enable VM communication.
- Ensure successful connectivity via `ping` commands.

### 4. Deploy Microservices
- **Database Server (VM3)**:
  - Install MySQL, create `mydb` database and `users` table.
  - Enable remote access for API Server.
- **API Server (VM2)**:
  - Install Node.js and Express.js.
  - Develop RESTful API for CRUD operations.
  - Connect API with MySQL database.
- **Web Server (VM1)**:
  - Install Lighttpd web server.
  - Deploy an HTML-based frontend to interact with the API.

## Architecture
The project follows a three-tier architecture:
- **VM1 (Web Server) → VM2 (API Server) → VM3 (Database Server)**
- The bridged network ensures seamless communication between the VMs.

## Testing & Validation
- **Frontend (VM1):** Verified CRUD operations via the user interface.
- **API Server (VM2):** Confirmed API calls return expected responses.
- **Database Server (VM3):** Ensured data consistency and accessibility.
- **Network Connectivity:** All VMs successfully communicate without packet loss.

## Observations & Insights
- **Performance:** CRUD operations executed with minimal latency.
- **Reliability:** No failures were observed during testing.
- **Scalability:** The architecture can be extended by adding more VMs.
- **Network Stability:** The bridged adapter ensures reliable connectivity.

## References
- [VirtualBox Documentation](https://www.virtualbox.org/manual/)
- [Node.js API Docs](https://nodejs.org/docs/latest/api/)
- [Express.js Documentation](https://expressjs.com/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [RESTful API Guide](https://restfulapi.net/)

## Resource
- [Recorded Video](https://drive.google.com/file/d/1QDCAUbed6xKeE-9bbDE1b2HHhfOjpGTB/view?usp=sharing)

## Author
- **Ankit Kumar Chauhan (M23CSA509)** - Email: m23csa509@iitj.ac.in

For any query, please reach out via email.

---
