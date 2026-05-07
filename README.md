# ✈️ YatraGo — Smart Travel Reservation System
### Powered by 8 DSA Algorithms | Flight • Train • Bus Booking

---

## 📌 Project Overview

YatraGo is a full-stack travel reservation system that allows users to search and book flights, trains, and buses across 200+ Indian cities. The project is built using **Node.js + Express** for the backend, **MySQL (XAMPP)** for the database, and **HTML/CSS/JavaScript** for the frontend.

What makes YatraGo unique is that **8 Data Structures and Algorithms (DSA)** are actively used in real features — not just mentioned, but actually running in every search, booking, and seat assignment.

---

## 👩‍💻 Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML5, CSS3, Vanilla JavaScript |
| Backend | Node.js, Express.js |
| Database | MySQL (via XAMPP phpMyAdmin) |
| Authentication | JWT (JSON Web Token) + bcryptjs |
| DSA Engine | Pure JavaScript (custom implementations) |

---

## 🧮 DSA Implementations (8 Algorithms)

### 1. 🏔 Min-Heap (Priority Queue)
- **Where used:** Seat assignment during booking
- **How it works:** Every passenger gets a priority score:
  - Disability = 1 (highest priority)
  - Women age 40+ = 2
  - Senior Citizen 60+ = 3
  - General = 4
- The Min-Heap always extracts the minimum priority value first, so disability passengers always get the best seat first.
- **Code location:** `backend/server.js` → `class MinHeap` → `computePriority()` → `assignSeat()`
- **Complexity:** Insert O(log n), Extract-Min O(log n)

---

### 2. 🗺 Dijkstra's Algorithm
- **Where used:** Finding cheapest/fastest route between cities
- **How it works:** Cities are nodes in a Graph. Flights, trains, and buses are weighted directed edges. Dijkstra's algorithm uses a Min-Heap internally to always process the cheapest unvisited city next.
- **Code location:** `backend/server.js` → `class Graph` → `dijkstra(source, target)`
- **Complexity:** O((V + E) log V)

---

### 3. 🌐 Graph (Adjacency List)
- **Where used:** City connection map for Dijkstra's Algorithm
- **How it works:** All city connections (flights, trains, buses) are stored as a weighted directed graph using an adjacency list. Three separate graphs are built — one for each transport type.
- **Code location:** `backend/server.js` → `class Graph` → `addEdge()`
- **Database:** `route_graph` table stores all edges with lat/lng coordinates
- **Space Complexity:** O(V + E)

---

### 4. 📚 Stack (LIFO)
- **Where used:** Search history — last 10 searches per user
- **How it works:** Every time a user searches, it is pushed onto their personal Stack. Newest search is always on top. When 11th search comes, the oldest is removed. Duplicate searches are removed before pushing.
- **Code location:** `backend/server.js` → `class SearchStack`
- **Database:** `search_history` table for persistence
- **Complexity:** Push O(1), Pop O(1)

---

### 5. 🔃 Priority Queue (Booking Waitlist)
- **Where used:** Booking queue — priority passengers processed first
- **How it works:** When seats are full, passengers join a waitlist queue backed by a Min-Heap. Disability passengers are dequeued first regardless of arrival order.
- **Code location:** `backend/server.js` → `class BookingQueue`
- **Database:** `booking_queue` table
- **Complexity:** Enqueue O(log n), Dequeue O(log n)

---

### 6. 🗂 Hash Map
- **Where used:** City name autocomplete (200+ cities)
- **How it works:** All city names are stored in a custom HashMap with prefix indexing. When a user types "Del", the key "del" instantly maps to ["Delhi"]. No database query needed — all in-memory.
- **Code location:** `backend/server.js` → `class CityHashMap`
- **Database:** `cities` table (loaded into HashMap at server start)
- **Complexity:** Lookup O(1), Autocomplete O(k) where k = prefix length

---

### 7. 🔀 Merge Sort
- **Where used:** Sorting all search results (flights, trains, buses)
- **How it works:** Custom Merge Sort implementation divides the results array in half recursively, sorts each half, then merges them in sorted order. It is stable — equal prices maintain original order. Applied on every search API call before sending response.
- **Code location:** `backend/server.js` → `mergeSort()` function
- **Complexity:** O(n log n) time, O(n) space

---

### 8. 🔎 Binary Search
- **Where used:** Price range filter on search results
- **How it works:** After Merge Sort, results are price-sorted. Binary Search finds the lower bound (first item ≥ minPrice) and upper bound (first item > maxPrice) in O(log n) — much faster than O(n) linear scan.
- **Code location:** `backend/server.js` → `bsLower()` + `bsUpper()` functions
- **Complexity:** O(log n) per search

---

## 🗄️ Database Tables (MySQL)

| Table | Purpose | DSA Connection |
|---|---|---|
| `users` | User accounts with age, gender, disability | Priority Queue input |
| `cities` | 200+ cities with lat/lng, airport/station names | HashMap source |
| `flights` | 70+ flights with Economy/Business/First class | Merge Sort + Binary Search |
| `trains` | 40+ trains with Sleeper/3AC/2AC/1AC/CC/EC class | Priority Queue seats |
| `buses` | 40+ buses with Volvo/AC/Non-AC types | Merge Sort |
| `bookings` | All booking records with seat assignments | Priority Queue output |
| `booking_passengers` | Individual passenger details per booking | Priority scores |
| `seats` | Seat categories — disability/senior/female/general | Min-Heap assignment |
| `route_graph` | City connections with lat/lng for Dijkstra | Graph edges |
| `search_history` | User search history (Stack persistence) | Stack LIFO |
| `booking_queue` | Waitlist queue | Priority Queue |

---

## ✈️ Transport Data

### Flights (70+ flights)
- Delhi → Mumbai: **10 flights** (5:30 AM to 11:00 PM)
- Delhi → Goa: **10 flights** (direct + via stops)
- Mumbai → Bangalore: **10 flights**
- Delhi → Chennai: **10 flights**
- Delhi → Kolkata: **10 flights**
- Mumbai → Delhi: **10 flights**
- Hyderabad → Delhi: **10 flights**
- Airlines: IndiGo, Air India, SpiceJet, Vistara, GoFirst, AirAsia
- Classes: Economy / Business / First Class (separate prices)
- Airports: IGI T1/T2/T3, CSIA T1/T2, KIA T2, NSCBI T1/T2, RGIA T1

### Trains (40+ trains)
- Delhi → Mumbai: **6 trains** (Rajdhani, August Kranti, Duronto, Paschim Express, Golden Temple Mail, Mumbai Superfast)
- Delhi → Agra: **6 trains** (Shatabdi, Gatimaan, Taj Express...)
- Delhi → Varanasi: **6 trains** (Vande Bharat, Kashi Vishwanath, Poorva...)
- Mumbai → Goa: **6 trains** (Tejas, Konkan Kanya, Mandovi, Jan Shatabdi...)
- Chennai → Bangalore: **6 trains** (Shatabdi, Brindavan, Lalbagh, Island...)
- Delhi → Jaipur: **5 trains**
- Delhi → Kolkata: **5 trains**
- Classes: Sleeper / 3AC / 2AC / 1AC / CC / EC
- Stations: Proper station names with all intermediate stops

### Buses (40+ buses)
- Delhi → Jaipur: **8 buses** (all timings 6AM to midnight)
- Mumbai → Pune: **6 buses**
- Bangalore → Goa: **7 buses**
- Chennai → Bangalore: **7 buses**
- Delhi → Dehradun: **6 buses**
- Mumbai → Goa: **6 buses**
- Types: Volvo AC / AC Sleeper / AC Seater / Non-AC Sleeper / Non-AC Seater / Luxury Sleeper
- Bus Stands: Kashmere Gate ISBT, Dadar Bus Depot, Majestic Terminal, CMBT Chennai

---

## 💰 Dynamic Pricing Logic

Prices increase as departure time approaches — exactly like real airlines:

| Time Before Departure | Price Multiplier |
|---|---|
| More than 24 hours | 1.0x (base price) |
| Less than 24 hours | 1.2x |
| Less than 12 hours | 1.4x |
| Less than 6 hours | 1.8x |
| Less than 2 hours | 2.2x |
| Seats less than 20% | Extra 1.15x surcharge |

---

## 🎯 Key Features

- ✅ Search flights, trains, buses with filters
- ✅ Price range filter using Binary Search
- ✅ Sort by price, duration, departure time (Merge Sort)
- ✅ Multi-passenger booking (add multiple passengers)
- ✅ Automatic seat assignment using Priority Queue
- ✅ Disability / Senior / Women 40+ get priority seats
- ✅ Route map with intermediate stops (Dijkstra path visualization)
- ✅ City autocomplete with 200+ cities (HashMap)
- ✅ Search history stack (last 10 searches)
- ✅ Dynamic pricing (early bird = cheaper)
- ✅ User authentication (JWT + bcrypt)
- ✅ My Bookings dashboard
- ✅ Cancel booking
- ✅ Sky blue professional UI

---

## 🚀 How to Run the Project

### Prerequisites
- XAMPP installed (Apache + MySQL)
- Node.js installed (v14 or above)
- VS Code (recommended)

### Step 1 — Extract ZIP
Extract the zip file and open the folder in VS Code.

### Step 2 — Setup Database
1. Open XAMPP Control Panel
2. Start **Apache** and **MySQL**
3. Open browser → `http://localhost/phpmyadmin`
4. Click **New** → Database name: `yatragodb` → Create
5. Click **Import** tab → Choose File → select `backend/yatragodb.sql` → Click **Go**

### Step 3 — Run Backend
Open terminal in VS Code:
```bash
cd backend
npm install
node server.js
``` 
