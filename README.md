# 🚌 YatraGo — Travel Ticket Booking System

> A full-stack travel booking web application supporting Bus, Train, and Flight ticket bookings.  
> Developed as a group college project at Graphic Era Hill University.

---

## 📌 About The Project

**YatraGo** is a web-based travel ticket booking platform where users can search routes, book tickets, and manage their travel across buses, trains, and flights.

The system includes a complete **MySQL relational database** with 11 tables handling users, routes, bookings, seats, and passenger management.

---

## ✨ Features

- 🔐 User Registration & Login
- ✈️ Search & Book — Flights, Trains, Buses
- 💺 Seat Selection & Booking Management
- 👥 Passenger Details per Booking
- 🗺️ Route Graph for city-to-city travel
- 📋 Booking History & Search History
- 🗄️ Complete MySQL Database (ready to import)

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | HTML, CSS, JavaScript |
| Backend | Node.js, Express.js |
| Database | MySQL (11 tables) |
| Tools | XAMPP, phpMyAdmin |

---

## 👨‍💻 Team & My Contribution

This was a **group college project**.

| Contribution | Details |
|-------------|---------|
| **My Role** | **SQL Database Design & QA Testing** |
| Database | Designed & built complete MySQL schema — 11 tables: users, cities, flights, trains, buses, bookings, booking_passengers, seats, route_graph, search_history, booking_queue |
| Testing | Wrote manual test cases for booking flow, login, seat selection, and passenger validation |
| QA | Identified and reported bugs during development |

---

## 🚀 How To Run

### Requirements
- [Node.js](https://nodejs.org/) installed
- [XAMPP](https://www.apachefriends.org/) installed (for MySQL)

### Step 1 — Clone the repository
```bash
git clone https://github.com/umange12/yatrago.git
cd yatrago
```

### Step 2 — Import the Database
1. Open **XAMPP** → Start **Apache** and **MySQL**
2. Open browser → go to `http://localhost/phpmyadmin`
3. Click **"Import"** → Select `backend/yatragodb.sql`
4. Click **"Go"** — database will be created automatically ✅

### Step 3 — Setup Backend
```bash
cd backend
npm install
```

### Step 4 — Configure Environment
Open `backend/.env` and update:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=yatragodb
```

### Step 5 — Run the Server
```bash
node server.js
```

### Step 6 — Open the App
Open browser → `http://localhost:3000`

---

## 🗄️ Database Schema

| Table | Purpose |
|-------|---------|
| users | User accounts & login |
| cities | All available cities |
| flights | Flight data & routes |
| trains | Train data & routes |
| buses | Bus data & routes |
| bookings | All bookings by users |
| booking_passengers | Passenger info per booking |
| seats | Seat availability |
| route_graph | City-to-city route mapping |
| search_history | User search logs |
| booking_queue | Queue management |

---

## 🧪 Test Cases (QA)

| Test Case | Input | Expected Output | Status |
|-----------|-------|-----------------|--------|
| TC-01: User Registration | Valid name, email, password | Account created | ✅ Pass |
| TC-02: Duplicate Email | Same email twice | Error shown | ✅ Pass |
| TC-03: Login valid user | Correct credentials | Login successful | ✅ Pass |
| TC-04: Login wrong password | Wrong password | Error message | ✅ Pass |
| TC-05: Search route | Source + Destination | Results shown | ✅ Pass |
| TC-06: Book ticket | Seat + passenger details | Booking confirmed | ✅ Pass |
| TC-07: Empty passenger name | Blank name | Validation error | ✅ Pass |
| TC-08: Seat already booked | Occupied seat | Seat not available error | ✅ Pass |

---

## 📄 License

Academic project — Graphic Era Hill University, Dehradun.

---

## 🙋‍♂️ Contact

**Umang Shaily**  
📧 shailyumang59@gmail.com  
🔗 [GitHub](https://github.com/umange12)
