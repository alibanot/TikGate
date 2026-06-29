# TikGate: Stadium E-Ticketing System

## Technologies Used
- **IDE**: IntelliJ IDEA
- **JDK**: 11
- **Server**: Apache Tomcat 9
- **Database**: Oracle Database 23ai Free
- **Front-end**: JSP, JSTL, Bootstrap 4
- **Back-end**: Java Servlets, JDBC

## Project Structure
- `src/main/java`: Java source files (Models, DAOs, Servlets, Utilities)
- `src/main/webapp`: Web resources (JSP pages, CSS, Images)
- `db_schema.sql`: Database schema definition
- `sample_data.sql`: Initial data for testing

## Setup Instructions
1. **Database Setup**:
   - Create/use an Oracle schema for TikGate.
   - Execute `db_schema.sql` to create tables.
   - Execute `sample_data.sql` to populate initial data.
2. **Project Configuration**:
   - Update `src/main/java/com/tikgate/util/DBConnection.java` with your database credentials.
3. **Deployment**:
   - Build the project using Maven: `mvn clean package`.
   - Deploy the generated `TikGate.war` to Tomcat 9.
   - Access the application at `http://localhost:8080/TikGate`.

## Default Credentials
- **Admin**: admin / admin123
- **Customer**: customer / cust123
- **Staff**: staff / staff123

## System Features Implemented:
| Feature | Description |
| :--- | :--- |
| **Authentication** | Role-based access control for Admin, Customer, and Staff with session management. |
| **Event Management** | Complete CRUD for Events, Categories, and Tournaments for Admins. |
| **Seat Management** | Admin tool to manage stadium sections, rows, and individual seats. |
| **Booking System** | End-to-end customer flow: browse -> select seat -> book -> pay. |
| **Ticket Generation** | Automatic generation of unique QR codes and PDF tickets upon successful payment. |
| **Staff Verification** | Staff interface to scan/enter QR codes, verify validity, and mark tickets as "USED". |
| **Reporting & Analytics**| Admin dashboard with real-time stats on users, events, tickets sold, and total revenue. |
