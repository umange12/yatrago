-- ============================================================
--  YatraGo FINAL v2 — Complete Database
--  Import in XAMPP phpMyAdmin
-- ============================================================
CREATE DATABASE IF NOT EXISTS yatragodb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE yatragodb;

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS booking_passengers;
DROP TABLE IF EXISTS booking_queue;
DROP TABLE IF EXISTS search_history;
DROP TABLE IF EXISTS seats;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS buses;
DROP TABLE IF EXISTS trains;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS route_graph;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE users (
  id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20) DEFAULT '',
  age INT DEFAULT 25,
  gender ENUM('male','female','other') DEFAULT 'other',
  disability TINYINT(1) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  airport_code VARCHAR(5) DEFAULT NULL,
  airport_name VARCHAR(200) DEFAULT NULL,
  station_name VARCHAR(200) DEFAULT NULL,
  lat DECIMAL(9,6) NOT NULL,
  lng DECIMAL(9,6) NOT NULL
);

CREATE TABLE flights (
  id VARCHAR(15) PRIMARY KEY,
  airline VARCHAR(100) NOT NULL,
  airline_code VARCHAR(5) NOT NULL,
  `from` VARCHAR(100) NOT NULL,
  `to` VARCHAR(100) NOT NULL,
  from_airport VARCHAR(200) DEFAULT '',
  to_airport VARCHAR(200) DEFAULT '',
  via_stops JSON DEFAULT NULL,
  date DATE NOT NULL,
  departure VARCHAR(10) NOT NULL,
  arrival VARCHAR(10) NOT NULL,
  duration_mins INT NOT NULL,
  price_economy INT DEFAULT NULL,
  price_business INT DEFAULT NULL,
  price_first INT DEFAULT NULL,
  seats_economy INT DEFAULT 0,
  seats_business INT DEFAULT 0,
  seats_first INT DEFAULT 0,
  is_direct TINYINT(1) DEFAULT 1
);

CREATE TABLE trains (
  id VARCHAR(15) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  number VARCHAR(20) NOT NULL,
  `from` VARCHAR(100) NOT NULL,
  `to` VARCHAR(100) NOT NULL,
  from_station VARCHAR(200) DEFAULT '',
  to_station VARCHAR(200) DEFAULT '',
  via_stops JSON DEFAULT NULL,
  date DATE NOT NULL,
  departure VARCHAR(10) NOT NULL,
  arrival VARCHAR(20) NOT NULL,
  duration_mins INT NOT NULL,
  price_sleeper INT DEFAULT NULL,
  price_3ac INT DEFAULT NULL,
  price_2ac INT DEFAULT NULL,
  price_1ac INT DEFAULT NULL,
  price_cc INT DEFAULT NULL,
  price_ec INT DEFAULT NULL,
  seats_sleeper INT DEFAULT 0,
  seats_3ac INT DEFAULT 0,
  seats_2ac INT DEFAULT 0,
  seats_1ac INT DEFAULT 0,
  seats_cc INT DEFAULT 0,
  seats_ec INT DEFAULT 0
);

CREATE TABLE buses (
  id VARCHAR(15) PRIMARY KEY,
  operator VARCHAR(100) NOT NULL,
  `from` VARCHAR(100) NOT NULL,
  `to` VARCHAR(100) NOT NULL,
  from_stop VARCHAR(200) DEFAULT '',
  to_stop VARCHAR(200) DEFAULT '',
  via_stops JSON DEFAULT NULL,
  date DATE NOT NULL,
  departure VARCHAR(10) NOT NULL,
  arrival VARCHAR(20) NOT NULL,
  duration_mins INT NOT NULL,
  bus_type VARCHAR(50) NOT NULL,
  price INT NOT NULL,
  seats INT NOT NULL
);

CREATE TABLE bookings (
  id VARCHAR(20) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  type ENUM('flight','train','bus') NOT NULL,
  item_id VARCHAR(15) NOT NULL,
  item_data JSON NOT NULL,
  travel_class VARCHAR(30) DEFAULT 'Economy',
  total_amount INT NOT NULL,
  contact_email VARCHAR(100) NOT NULL,
  contact_phone VARCHAR(20) NOT NULL,
  seat_assignments JSON DEFAULT NULL,
  priority_label VARCHAR(80) DEFAULT 'General',
  status ENUM('Confirmed','Cancelled') DEFAULT 'Confirmed',
  booked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE booking_passengers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id VARCHAR(20) NOT NULL,
  passenger_name VARCHAR(100) NOT NULL,
  age INT NOT NULL,
  gender ENUM('male','female','other') DEFAULT 'other',
  disability TINYINT(1) DEFAULT 0,
  seat_number VARCHAR(10) DEFAULT NULL,
  seat_category VARCHAR(20) DEFAULT 'general',
  priority_score INT DEFAULT 4,
  FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

CREATE TABLE seats (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transport_id VARCHAR(15) NOT NULL,
  transport_type ENUM('flight','train','bus') NOT NULL,
  travel_class VARCHAR(30) NOT NULL DEFAULT 'Economy',
  seat_number VARCHAR(10) NOT NULL,
  seat_category ENUM('disability','senior','female','general') NOT NULL,
  is_reserved TINYINT(1) DEFAULT 0,
  booking_id VARCHAR(20) DEFAULT NULL,
  UNIQUE KEY uniq_seat (transport_id, transport_type, travel_class, seat_number)
);

CREATE TABLE route_graph (
  id INT AUTO_INCREMENT PRIMARY KEY,
  city_from VARCHAR(100) NOT NULL,
  city_to VARCHAR(100) NOT NULL,
  from_lat DECIMAL(9,6) DEFAULT 0,
  from_lng DECIMAL(9,6) DEFAULT 0,
  to_lat DECIMAL(9,6) DEFAULT 0,
  to_lng DECIMAL(9,6) DEFAULT 0,
  distance_km INT NOT NULL,
  base_price INT NOT NULL,
  transport_type ENUM('flight','train','bus') NOT NULL,
  duration_mins INT NOT NULL
);

CREATE TABLE search_history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  search_from VARCHAR(100),
  search_to VARCHAR(100),
  search_type ENUM('flights','trains','buses') NOT NULL,
  travel_class VARCHAR(30) DEFAULT NULL,
  searched_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE booking_queue (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  transport_id VARCHAR(15) NOT NULL,
  transport_type ENUM('flight','train','bus') NOT NULL,
  passenger_name VARCHAR(100),
  priority_score INT DEFAULT 4,
  queue_status ENUM('waiting','processed') DEFAULT 'waiting',
  queued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================================
-- CITIES (200+)
-- ============================================================
INSERT INTO cities (name,state,airport_code,airport_name,station_name,lat,lng) VALUES
('Delhi','Delhi','DEL','Indira Gandhi International Airport T3','New Delhi Railway Station',28.6139,77.2090),
('Mumbai','Maharashtra','BOM','Chhatrapati Shivaji Maharaj Intl Airport','Mumbai Central Railway Station',19.0760,72.8777),
('Bangalore','Karnataka','BLR','Kempegowda International Airport','KSR Bengaluru City Junction',12.9716,77.5946),
('Chennai','Tamil Nadu','MAA','Chennai International Airport','Chennai Central Station',13.0827,80.2707),
('Kolkata','West Bengal','CCU','Netaji Subhas Chandra Bose Intl Airport','Howrah Junction',22.5726,88.3639),
('Hyderabad','Telangana','HYD','Rajiv Gandhi International Airport','Hyderabad Deccan Station',17.3850,78.4867),
('Pune','Maharashtra','PNQ','Pune Airport','Pune Junction',18.5204,73.8567),
('Goa','Goa','GOI','Goa International Airport (Dabolim)','Madgaon Junction',15.4909,73.8278),
('Jaipur','Rajasthan','JAI','Jaipur International Airport','Jaipur Junction',26.9124,75.7873),
('Agra','Uttar Pradesh',NULL,NULL,'Agra Cantt Railway Station',27.1767,78.0081),
('Varanasi','Uttar Pradesh','VNS','Lal Bahadur Shastri Airport','Varanasi Junction',25.3176,82.9739),
('Lucknow','Uttar Pradesh','LKO','Chaudhary Charan Singh Airport','Lucknow Charbagh Station',26.8467,80.9462),
('Ahmedabad','Gujarat','AMD','Sardar Vallabhbhai Patel Intl Airport','Ahmedabad Junction',23.0225,72.5714),
('Surat','Gujarat','STV','Surat Airport','Surat Junction',21.1702,72.8311),
('Kochi','Kerala','COK','Cochin International Airport','Ernakulam Junction',9.9312,76.2673),
('Amritsar','Punjab','ATQ','Sri Guru Ram Dass Jee Intl Airport','Amritsar Junction',31.6340,74.8723),
('Chandigarh','Punjab','IXC','Chandigarh Airport','Chandigarh Junction',30.7333,76.7794),
('Bhopal','Madhya Pradesh','BHO','Raja Bhoj Airport','Bhopal Junction',23.2599,77.4126),
('Indore','Madhya Pradesh','IDR','Devi Ahilyabai Holkar Airport','Indore Junction',22.7196,75.8577),
('Nagpur','Maharashtra','NAG','Dr. Babasaheb Ambedkar Intl Airport','Nagpur Junction',21.1458,79.0882),
('Coimbatore','Tamil Nadu','CJB','Coimbatore International Airport','Coimbatore Junction',11.0168,76.9558),
('Thiruvananthapuram','Kerala','TRV','Trivandrum International Airport','Trivandrum Central',8.5241,76.9366),
('Mangalore','Karnataka','IXE','Mangalore International Airport','Mangalore Central',12.9141,74.8560),
('Mysore','Karnataka',NULL,NULL,'Mysuru Junction',12.2958,76.6394),
('Vijayawada','Andhra Pradesh','VGA','Vijayawada Airport','Vijayawada Junction',16.5062,80.6480),
('Visakhapatnam','Andhra Pradesh','VTZ','Visakhapatnam Airport','Visakhapatnam Junction',17.6868,83.2185),
('Nashik','Maharashtra','ISK','Nashik Airport','Nashik Road Station',19.9975,73.7898),
('Aurangabad','Maharashtra','IXU','Aurangabad Airport','Aurangabad Junction',19.8762,75.3433),
('Jodhpur','Rajasthan','JDH','Jodhpur Airport','Jodhpur Junction',26.2389,73.0243),
('Udaipur','Rajasthan','UDR','Maharana Pratap Airport','Udaipur City Station',24.5854,73.7125),
('Ajmer','Rajasthan',NULL,NULL,'Ajmer Junction',26.4499,74.6399),
('Kota','Rajasthan',NULL,NULL,'Kota Junction',25.2138,75.8648),
('Dehradun','Uttarakhand','DED','Jolly Grant Airport','Dehradun Junction',30.3165,78.0322),
('Haridwar','Uttarakhand',NULL,NULL,'Haridwar Junction',29.9457,78.1642),
('Patna','Bihar','PAT','Jay Prakash Narayan Airport','Patna Junction',25.5941,85.1376),
('Ranchi','Jharkhand','IXR','Birsa Munda Airport','Ranchi Junction',23.3441,85.3096),
('Bhubaneswar','Odisha','BBI','Biju Patnaik International Airport','Bhubaneswar Station',20.2961,85.8245),
('Guwahati','Assam','GAU','Lokpriya Gopinath Bordoloi Intl Airport','Guwahati Station',26.1445,91.7362),
('Srinagar','Jammu & Kashmir','SXR','Sheikh ul-Alam International Airport','NA',34.0837,74.7973),
('Jammu','Jammu & Kashmir','IXJ','Jammu Airport','Jammu Tawi Station',32.7266,74.8570),
('Leh','Ladakh','IXL','Kushok Bakula Rimpochee Airport','NA',34.1526,77.5771),
('Shimla','Himachal Pradesh',NULL,NULL,'Shimla Station',31.1048,77.1734),
('Allahabad','Uttar Pradesh','IXD','Bamrauli Airport','Prayagraj Junction',25.4358,81.8463),
('Kanpur','Uttar Pradesh','KNU','Kanpur Airport','Kanpur Central',26.4499,80.3319),
('Prayagraj','Uttar Pradesh',NULL,NULL,'Prayagraj Junction',25.4358,81.8463),
('Vadodara','Gujarat','BDQ','Vadodara Airport','Vadodara Junction',22.3072,73.1812),
('Rajkot','Gujarat','RAJ','Rajkot Airport','Rajkot Junction',22.3039,70.8022),
('Raipur','Chhattisgarh','RPR','Raipur Airport','Raipur Junction',21.2514,81.6296),
('Jabalpur','Madhya Pradesh','JLR','Jabalpur Airport','Jabalpur Junction',23.1815,79.9864),
('Gwalior','Madhya Pradesh','GWL','Gwalior Airport','Gwalior Junction',26.2183,78.1828),
('Madurai','Tamil Nadu','IXM','Madurai Airport','Madurai Junction',9.9252,78.1198),
('Trichy','Tamil Nadu','TRZ','Tiruchirappalli International Airport','Tiruchirappalli Junction',10.7905,78.7047),
('Calicut','Kerala','CCJ','Calicut International Airport','Kozhikode Station',11.2588,75.7804),
('Siliguri','West Bengal','IXB','Bagdogra Airport','New Jalpaiguri Junction',26.7271,88.3952),
('Gorakhpur','Uttar Pradesh','GOP','Gorakhpur Airport','Gorakhpur Junction',26.7606,83.3732),
('Mathura','Uttar Pradesh',NULL,NULL,'Mathura Junction',27.4924,77.6737),
('Aligarh','Uttar Pradesh',NULL,NULL,'Aligarh Junction',27.8974,78.0880),
('Vellore','Tamil Nadu',NULL,NULL,'Katpadi Junction',12.9165,79.1325),
('Krishnagiri','Tamil Nadu',NULL,NULL,'Krishnagiri Station',12.5186,78.2137),
('Hosur','Tamil Nadu',NULL,NULL,'Hosur Station',12.7409,77.8253),
('Hubli','Karnataka',NULL,NULL,'Hubballi Junction',15.3647,75.1240),
('Belgaum','Karnataka',NULL,NULL,'Belagavi Junction',15.8497,74.4977),
('Dharwad','Karnataka',NULL,NULL,'Dharwad Station',15.4589,74.9956),
('Ratnagiri','Maharashtra',NULL,NULL,'Ratnagiri Station',16.9902,73.3120),
('Sawantwadi','Maharashtra',NULL,NULL,'Sawantwadi Road',15.9101,73.8141),
('Kudal','Maharashtra',NULL,NULL,'Kudal Station',16.0556,73.6871),
('Roha','Maharashtra',NULL,NULL,'Roha Station',18.4413,73.1158),
('Kankavli','Maharashtra',NULL,NULL,'Kankavli Station',16.5773,73.7125),
('Manmad','Maharashtra',NULL,NULL,'Manmad Junction',20.2542,74.4390),
('Bhusawal','Maharashtra',NULL,NULL,'Bhusawal Junction',21.0455,75.7943),
('Panvel','Maharashtra',NULL,NULL,'Panvel Station',18.9894,73.1175),
('Thane','Maharashtra',NULL,NULL,'Thane Station',19.1663,72.9963),
('Mirzapur','Uttar Pradesh',NULL,NULL,'Mirzapur Station',25.1460,82.5690),
('Gaya','Bihar',NULL,NULL,'Gaya Junction',24.7914,85.0002),
('Dhanbad','Jharkhand',NULL,NULL,'Dhanbad Junction',23.7957,86.4304),
('Jamshedpur','Jharkhand',NULL,NULL,'Tatanagar Junction',22.8046,86.2029),
('Asansol','West Bengal',NULL,NULL,'Asansol Junction',23.6739,86.9524),
('Kharagpur','West Bengal',NULL,NULL,'Kharagpur Junction',22.3302,87.3237),
('Puri','Odisha',NULL,NULL,'Puri Station',19.8135,85.8312),
('Cuttack','Odisha',NULL,NULL,'Cuttack Station',20.4625,85.8830),
('Rourkela','Odisha',NULL,NULL,'Rourkela Station',22.2604,84.8536),
('Tirupati','Andhra Pradesh','TIR','Tirupati Airport','Tirupati Station',13.6288,79.4192),
('Nellore','Andhra Pradesh',NULL,NULL,'Nellore Station',14.4426,79.9865),
('Warangal','Telangana',NULL,NULL,'Warangal Station',18.0000,79.5880),
('Salem','Tamil Nadu','SXV','Salem Airport','Salem Junction',11.6643,78.1460),
('Erode','Tamil Nadu',NULL,NULL,'Erode Junction',11.3410,77.7172),
('Coimbatore','Tamil Nadu','CJB','Coimbatore Airport','Coimbatore Junction',11.0168,76.9558),
('Ahmedabad','Gujarat','AMD','Sardar Vallabhbhai Patel Intl Airport','Ahmedabad Junction',23.0225,72.5714),
('Rewari','Haryana',NULL,NULL,'Rewari Junction',28.1964,76.6170),
('Alwar','Rajasthan',NULL,NULL,'Alwar Junction',27.5530,76.6346),
('Behror','Rajasthan',NULL,NULL,'Behror Bus Stop',27.8833,76.2833),
('Shahjahanpur','Rajasthan',NULL,NULL,'Shahjahanpur Bus Stop',27.5833,76.1167),
('Manesar','Haryana',NULL,NULL,'Manesar Bus Stop',28.3590,76.9380),
('Gurgaon','Haryana',NULL,NULL,'Gurugram Bus Stand',28.4595,77.0266),
('Khopoli','Maharashtra',NULL,NULL,'Khopoli Bus Stop',18.7867,73.3358),
('Khalapur','Maharashtra',NULL,NULL,'Khalapur Bus Stop',18.8278,73.2778),
('Electronic City','Karnataka',NULL,NULL,'Electronic City Bus Stop',12.8458,77.6611),
('Londa','Karnataka',NULL,NULL,'Londa Junction',15.4667,74.5167),
('Borivali','Maharashtra',NULL,NULL,'Borivali Station',19.2322,72.8566),
('Ratlam','Madhya Pradesh',NULL,NULL,'Ratlam Junction',23.3325,75.0376),
('Khed','Maharashtra',NULL,NULL,'Khed Station',17.7167,73.3833),
('Jolarpettai','Tamil Nadu',NULL,NULL,'Jolarpettai Junction',12.5667,78.5833),
('Ambur','Tamil Nadu',NULL,NULL,'Ambur Station',12.7960,78.7150),
('Arakkonam','Tamil Nadu',NULL,NULL,'Arakkonam Junction',13.0833,79.6667),
('Manmad','Maharashtra',NULL,NULL,'Manmad Junction',20.2542,74.4390),
('Nagda','Madhya Pradesh',NULL,NULL,'Nagda Junction',23.4500,75.4167),
('Surat','Gujarat','STV','Surat Airport','Surat Junction',21.1702,72.8311);

-- ============================================================
-- FLIGHTS (10 per major route)
-- ============================================================
INSERT INTO flights VALUES
-- DELHI → MUMBAI (10 flights, different times)
('F001','IndiGo','6E','Delhi','Mumbai','IGI Airport Terminal 1','CSIA Terminal 2',NULL,'2025-06-10','05:30','07:55',145,3499,NULL,NULL,120,0,0,1),
('F002','Air India','AI','Delhi','Mumbai','IGI Airport Terminal 3','CSIA Terminal 2',NULL,'2025-06-10','07:00','09:25',145,4299,11999,21999,90,24,8,1),
('F003','SpiceJet','SJ','Delhi','Mumbai','IGI Airport Terminal 3','CSIA Terminal 1',NULL,'2025-06-10','09:30','11:55',145,3199,NULL,NULL,140,0,0,1),
('F004','Vistara','UK','Delhi','Mumbai','IGI Airport Terminal 2','CSIA Terminal 2',NULL,'2025-06-10','11:00','13:25',145,5499,13999,24999,100,28,8,1),
('F005','GoFirst','G8','Delhi','Mumbai','IGI Airport Terminal 1','CSIA Terminal 1',NULL,'2025-06-10','13:30','15:55',145,2999,NULL,NULL,130,0,0,1),
('F006','AirAsia','I5','Delhi','Mumbai','IGI Airport Terminal 3','CSIA Terminal 2',NULL,'2025-06-10','16:00','18:25',145,2799,NULL,NULL,150,0,0,1),
('F007','IndiGo','6E','Delhi','Mumbai','IGI Airport Terminal 1','CSIA Terminal 2',NULL,'2025-06-10','18:30','20:55',145,3699,8999,NULL,110,20,0,1),
('F008','Air India','AI','Delhi','Mumbai','IGI Airport Terminal 3','CSIA Terminal 2',NULL,'2025-06-10','20:00','22:25',145,4599,12499,22999,80,20,6,1),
('F009','IndiGo','6E','Delhi','Mumbai','IGI Airport Terminal 1','CSIA Terminal 2','["Jaipur"]','2025-06-10','07:30','11:00',210,2499,NULL,NULL,160,0,0,0),
('F010','AirAsia','I5','Delhi','Mumbai','IGI Airport Terminal 3','CSIA Terminal 1','["Ahmedabad"]','2025-06-10','10:00','14:00',240,2299,NULL,NULL,170,0,0,0),
-- DELHI → GOA (10 flights)
('F011','IndiGo','6E','Delhi','Goa','IGI Airport Terminal 1','Goa Intl Airport',NULL,'2025-06-10','06:00','08:35',155,5299,NULL,NULL,100,0,0,1),
('F012','Air India','AI','Delhi','Goa','IGI Airport Terminal 3','Goa Intl Airport',NULL,'2025-06-10','08:30','11:05',155,6499,15999,NULL,80,20,0,1),
('F013','SpiceJet','SJ','Delhi','Goa','IGI Airport Terminal 3','Goa Intl Airport',NULL,'2025-06-10','11:00','13:40',160,4899,NULL,NULL,120,0,0,1),
('F014','Vistara','UK','Delhi','Goa','IGI Airport Terminal 2','Goa Intl Airport',NULL,'2025-06-10','14:00','16:35',155,7299,17999,NULL,80,24,0,1),
('F015','GoFirst','G8','Delhi','Goa','IGI Airport Terminal 1','Goa Intl Airport',NULL,'2025-06-10','16:30','19:10',160,4599,NULL,NULL,110,0,0,1),
('F016','IndiGo','6E','Delhi','Goa','IGI Airport Terminal 1','Goa Intl Airport',NULL,'2025-06-10','18:00','20:35',155,5099,NULL,NULL,100,0,0,1),
('F017','Air India','AI','Delhi','Goa','IGI Airport Terminal 3','Goa Intl Airport',NULL,'2025-06-10','20:30','23:05',155,6299,15499,NULL,75,18,0,1),
('F018','SpiceJet','SJ','Delhi','Goa','IGI Airport Terminal 3','Goa Intl Airport',NULL,'2025-06-10','22:00','00:40',160,4299,NULL,NULL,115,0,0,1),
('F019','IndiGo','6E','Delhi','Goa','IGI Airport Terminal 1','Goa Intl Airport','["Mumbai"]','2025-06-10','09:00','13:00',240,3999,NULL,NULL,150,0,0,0),
('F020','AirAsia','I5','Delhi','Goa','IGI Airport Terminal 3','Goa Intl Airport','["Hyderabad"]','2025-06-10','12:00','17:00',300,3699,NULL,NULL,160,0,0,0),
-- MUMBAI → BANGALORE (10 flights)
('F021','IndiGo','6E','Mumbai','Bangalore','CSIA Terminal 1','KIA Terminal 2',NULL,'2025-06-10','06:30','08:20',110,3299,NULL,NULL,130,0,0,1),
('F022','Vistara','UK','Mumbai','Bangalore','CSIA Terminal 2','KIA Terminal 2',NULL,'2025-06-10','08:00','09:55',115,5999,13499,22999,80,24,8,1),
('F023','Air India','AI','Mumbai','Bangalore','CSIA Terminal 2','KIA Terminal 2',NULL,'2025-06-10','10:30','12:25',115,4499,10999,NULL,100,20,0,1),
('F024','SpiceJet','SJ','Mumbai','Bangalore','CSIA Terminal 1','KIA Terminal 1',NULL,'2025-06-10','13:00','14:50',110,3499,NULL,NULL,120,0,0,1),
('F025','GoFirst','G8','Mumbai','Bangalore','CSIA Terminal 1','KIA Terminal 1',NULL,'2025-06-10','15:30','17:25',115,2899,NULL,NULL,140,0,0,1),
('F026','IndiGo','6E','Mumbai','Bangalore','CSIA Terminal 1','KIA Terminal 2',NULL,'2025-06-10','17:00','18:50',110,3799,8499,NULL,110,18,0,1),
('F027','Air India','AI','Mumbai','Bangalore','CSIA Terminal 2','KIA Terminal 2',NULL,'2025-06-10','19:30','21:25',115,4799,11499,NULL,90,20,0,1),
('F028','Vistara','UK','Mumbai','Bangalore','CSIA Terminal 2','KIA Terminal 2',NULL,'2025-06-10','21:00','22:55',115,5299,13999,23999,80,22,6,1),
('F029','SpiceJet','SJ','Mumbai','Bangalore','CSIA Terminal 1','KIA Terminal 1',NULL,'2025-06-10','22:30','00:25',115,3199,NULL,NULL,125,0,0,1),
('F030','AirAsia','I5','Mumbai','Bangalore','CSIA Terminal 2','KIA Terminal 1',NULL,'2025-06-10','07:00','08:55',115,2799,NULL,NULL,150,0,0,1),
-- DELHI → CHENNAI (10 flights)
('F031','Air India','AI','Delhi','Chennai','IGI Airport Terminal 3','MAA Terminal 2',NULL,'2025-06-10','06:00','08:55',175,5299,12999,NULL,90,20,0,1),
('F032','IndiGo','6E','Delhi','Chennai','IGI Airport Terminal 1','MAA Terminal 2',NULL,'2025-06-10','08:00','10:55',175,4199,NULL,NULL,130,0,0,1),
('F033','SpiceJet','SJ','Delhi','Chennai','IGI Airport Terminal 3','MAA Terminal 1',NULL,'2025-06-10','10:30','13:25',175,3799,NULL,NULL,120,0,0,1),
('F034','Vistara','UK','Delhi','Chennai','IGI Airport Terminal 2','MAA Terminal 2',NULL,'2025-06-10','13:00','15:55',175,6299,15999,NULL,80,24,0,1),
('F035','GoFirst','G8','Delhi','Chennai','IGI Airport Terminal 1','MAA Terminal 1',NULL,'2025-06-10','15:30','18:25',175,3999,NULL,NULL,110,0,0,1),
('F036','IndiGo','6E','Delhi','Chennai','IGI Airport Terminal 1','MAA Terminal 2',NULL,'2025-06-10','17:00','19:55',175,4399,NULL,NULL,120,0,0,1),
('F037','Air India','AI','Delhi','Chennai','IGI Airport Terminal 3','MAA Terminal 2',NULL,'2025-06-10','19:00','21:55',175,5599,13499,NULL,80,18,0,1),
('F038','SpiceJet','SJ','Delhi','Chennai','IGI Airport Terminal 3','MAA Terminal 1',NULL,'2025-06-10','21:00','23:55',175,3599,NULL,NULL,115,0,0,1),
('F039','IndiGo','6E','Delhi','Chennai','IGI Airport Terminal 1','MAA Terminal 2','["Hyderabad"]','2025-06-10','09:00','13:30',270,3499,NULL,NULL,150,0,0,0),
('F040','AirAsia','I5','Delhi','Chennai','IGI Airport Terminal 3','MAA Terminal 1','["Mumbai"]','2025-06-10','11:00','16:00',300,3199,NULL,NULL,160,0,0,0),
-- DELHI → KOLKATA (10 flights)
('F041','Air India','AI','Delhi','Kolkata','IGI Airport Terminal 3','NSCBI Terminal 2',NULL,'2025-06-10','06:30','09:00',150,4499,11999,NULL,90,20,0,1),
('F042','IndiGo','6E','Delhi','Kolkata','IGI Airport Terminal 1','NSCBI Terminal 2',NULL,'2025-06-10','08:30','11:05',155,3799,NULL,NULL,130,0,0,1),
('F043','SpiceJet','SJ','Delhi','Kolkata','IGI Airport Terminal 3','NSCBI Terminal 1',NULL,'2025-06-10','11:00','13:35',155,3499,NULL,NULL,120,0,0,1),
('F044','Vistara','UK','Delhi','Kolkata','IGI Airport Terminal 2','NSCBI Terminal 2',NULL,'2025-06-10','13:30','16:05',155,5999,14499,NULL,80,22,0,1),
('F045','GoFirst','G8','Delhi','Kolkata','IGI Airport Terminal 1','NSCBI Terminal 1',NULL,'2025-06-10','16:00','18:35',155,3299,NULL,NULL,110,0,0,1),
('F046','IndiGo','6E','Delhi','Kolkata','IGI Airport Terminal 1','NSCBI Terminal 2',NULL,'2025-06-10','18:00','20:35',155,4099,NULL,NULL,120,0,0,1),
('F047','Air India','AI','Delhi','Kolkata','IGI Airport Terminal 3','NSCBI Terminal 2',NULL,'2025-06-10','20:00','22:35',155,4799,12499,NULL,80,18,0,1),
('F048','SpiceJet','SJ','Delhi','Kolkata','IGI Airport Terminal 3','NSCBI Terminal 1',NULL,'2025-06-10','22:00','00:35',155,3299,NULL,NULL,115,0,0,1),
('F049','IndiGo','6E','Delhi','Kolkata','IGI Airport Terminal 1','NSCBI Terminal 2','["Varanasi"]','2025-06-10','09:30','13:30',240,2999,NULL,NULL,150,0,0,0),
('F050','AirAsia','I5','Delhi','Kolkata','IGI Airport Terminal 3','NSCBI Terminal 1','["Patna"]','2025-06-10','12:00','16:30',270,2799,NULL,NULL,160,0,0,0),
-- MUMBAI → DELHI (10 flights)
('F051','IndiGo','6E','Mumbai','Delhi','CSIA Terminal 1','IGI Terminal 1',NULL,'2025-06-10','05:00','07:25',145,3199,8499,NULL,120,18,0,1),
('F052','Air India','AI','Mumbai','Delhi','CSIA Terminal 2','IGI Terminal 3',NULL,'2025-06-10','07:30','09:55',145,4599,11499,20999,90,24,8,1),
('F053','SpiceJet','SJ','Mumbai','Delhi','CSIA Terminal 1','IGI Terminal 3',NULL,'2025-06-10','10:00','12:25',145,3099,NULL,NULL,140,0,0,1),
('F054','Vistara','UK','Mumbai','Delhi','CSIA Terminal 2','IGI Terminal 2',NULL,'2025-06-10','12:30','14:55',145,5299,13499,23999,100,28,8,1),
('F055','GoFirst','G8','Mumbai','Delhi','CSIA Terminal 1','IGI Terminal 1',NULL,'2025-06-10','15:00','17:25',145,2799,NULL,NULL,130,0,0,1),
('F056','IndiGo','6E','Mumbai','Delhi','CSIA Terminal 1','IGI Terminal 1',NULL,'2025-06-10','17:30','19:55',145,3599,9499,NULL,110,20,0,1),
('F057','Air India','AI','Mumbai','Delhi','CSIA Terminal 2','IGI Terminal 3',NULL,'2025-06-10','19:00','21:25',145,4899,12499,21999,80,20,6,1),
('F058','SpiceJet','SJ','Mumbai','Delhi','CSIA Terminal 1','IGI Terminal 3',NULL,'2025-06-10','21:00','23:25',145,3399,NULL,NULL,130,0,0,1),
('F059','AirAsia','I5','Mumbai','Delhi','CSIA Terminal 2','IGI Terminal 3',NULL,'2025-06-10','22:30','00:55',145,2699,NULL,NULL,150,0,0,1),
('F060','Vistara','UK','Mumbai','Delhi','CSIA Terminal 2','IGI Terminal 2',NULL,'2025-06-10','08:00','10:25',145,5799,14499,25999,80,22,6,1),
-- HYDERABAD routes (10)
('F061','IndiGo','6E','Hyderabad','Delhi','RGIA Terminal 1','IGI Terminal 1',NULL,'2025-06-10','05:30','07:55',145,3999,NULL,NULL,130,0,0,1),
('F062','Air India','AI','Hyderabad','Delhi','RGIA Terminal 1','IGI Terminal 3',NULL,'2025-06-10','08:00','10:25',145,5299,12999,NULL,80,20,0,1),
('F063','SpiceJet','SJ','Hyderabad','Delhi','RGIA Terminal 1','IGI Terminal 3',NULL,'2025-06-10','10:30','12:55',145,3699,NULL,NULL,120,0,0,1),
('F064','Vistara','UK','Hyderabad','Delhi','RGIA Terminal 1','IGI Terminal 2',NULL,'2025-06-10','13:00','15:25',145,5999,14999,NULL,80,22,0,1),
('F065','GoFirst','G8','Hyderabad','Delhi','RGIA Terminal 1','IGI Terminal 1',NULL,'2025-06-10','15:30','17:55',145,3199,NULL,NULL,120,0,0,1),
('F066','IndiGo','6E','Hyderabad','Delhi','RGIA Terminal 1','IGI Terminal 1',NULL,'2025-06-10','17:00','19:25',145,4199,NULL,NULL,110,0,0,1),
('F067','Air India','AI','Hyderabad','Delhi','RGIA Terminal 1','IGI Terminal 3',NULL,'2025-06-10','19:00','21:25',145,5499,13499,NULL,75,18,0,1),
('F068','SpiceJet','SJ','Hyderabad','Delhi','RGIA Terminal 1','IGI Terminal 3',NULL,'2025-06-10','21:00','23:25',145,3499,NULL,NULL,115,0,0,1),
('F069','IndiGo','6E','Hyderabad','Mumbai','RGIA Terminal 1','CSIA Terminal 1',NULL,'2025-06-10','07:00','08:35',95,2999,NULL,NULL,120,0,0,1),
('F070','Air India','AI','Hyderabad','Mumbai','RGIA Terminal 1','CSIA Terminal 2',NULL,'2025-06-10','14:00','15:35',95,3999,9999,NULL,80,18,0,1);

-- ============================================================
-- TRAINS (6 per route with proper stations and stops)
-- ============================================================
INSERT INTO trains VALUES
-- DELHI → MUMBAI (6 trains)
('T001','Rajdhani Express','12951','Delhi','Mumbai','New Delhi Railway Station','Mumbai Central Station','["Kota Junction","Vadodara Junction","Surat Junction"]','2025-06-10','16:55','08:15',915,NULL,1850,2600,4200,NULL,NULL,0,200,120,40,0,0),
('T002','August Kranti Rajdhani','12953','Delhi','Mumbai','Hazrat Nizamuddin Station','Mumbai Central Station','["Vadodara Junction","Surat Junction","Borivali Station"]','2025-06-10','17:40','10:26',1006,NULL,1950,2750,4400,NULL,NULL,0,180,100,30,0,0),
('T003','Duronto Express','12267','Delhi','Mumbai','Hazrat Nizamuddin Station','Lokmanya Tilak Terminal','[]','2025-06-10','22:30','14:45',975,NULL,1700,2450,NULL,NULL,NULL,0,250,150,0,0,0),
('T004','Paschim Express','12925','Delhi','Mumbai','New Delhi Railway Station','Mumbai Central Station','["Ahmedabad Junction","Surat Junction","Vadodara Junction","Kota Junction"]','2025-06-10','11:25','06:40',1155,650,1250,1900,NULL,NULL,NULL,200,180,80,0,0,0),
('T005','Golden Temple Mail','12903','Delhi','Mumbai','New Delhi Railway Station','Mumbai Central Station','["Jaipur Junction","Ahmedabad Junction","Vadodara Junction","Surat Junction"]','2025-06-10','09:40','08:55',1395,550,1100,1700,NULL,NULL,NULL,220,160,60,0,0,0),
('T006','Mumbai Superfast','12245','Delhi','Mumbai','New Delhi Railway Station','Lokmanya Tilak Terminal','["Agra Cantt","Kota Junction","Ratlam Junction","Vadodara Junction"]','2025-06-10','06:30','00:30',1080,700,1350,2000,NULL,NULL,NULL,190,150,70,0,0,0),
-- DELHI → AGRA (6 trains)
('T007','Shatabdi Express','12001','Delhi','Agra','New Delhi Railway Station','Agra Cantt Station','[]','2025-06-10','06:00','08:10',130,NULL,NULL,NULL,NULL,750,1100,0,0,0,0,150,60),
('T008','Gatimaan Express','12049','Delhi','Agra','Hazrat Nizamuddin Station','Agra Cantt Station','[]','2025-06-10','08:10','09:50',100,NULL,NULL,NULL,NULL,NULL,995,0,0,0,0,0,100),
('T009','Taj Express','12279','Delhi','Agra','Hazrat Nizamuddin Station','Agra Cantt Station','[]','2025-06-10','07:15','09:55',160,NULL,NULL,NULL,NULL,680,NULL,0,0,0,0,120,0),
('T010','Intercity Express','12627','Delhi','Agra','New Delhi Railway Station','Agra Cantt Station','["Mathura Junction"]','2025-06-10','15:30','18:05',155,350,NULL,NULL,NULL,NULL,NULL,100,0,0,0,0,0),
('T011','Agra SF Express','12179','Delhi','Agra','New Delhi Railway Station','Agra Cantt Station','["Mathura Junction"]','2025-06-10','18:00','21:15',195,280,650,NULL,NULL,NULL,NULL,120,60,0,0,0,0),
('T012','Bhopal SF Express','12155','Delhi','Agra','New Delhi Railway Station','Agra Cantt Station','["Gwalior Junction"]','2025-06-10','06:25','09:40',195,350,750,1100,NULL,NULL,NULL,150,100,40,0,0,0),
-- DELHI → VARANASI (6 trains)
('T013','Vande Bharat Express','22439','Delhi','Varanasi','New Delhi Railway Station','Varanasi Junction','["Prayagraj Junction"]','2025-06-10','06:00','14:00',480,NULL,NULL,NULL,NULL,1200,1600,0,0,0,0,80,40),
('T014','Kashi Vishwanath Express','13307','Delhi','Varanasi','New Delhi Railway Station','Varanasi Junction','["Aligarh Junction","Kanpur Central","Prayagraj Junction"]','2025-06-10','14:10','06:40',990,650,1300,1950,NULL,NULL,NULL,180,140,50,0,0,0),
('T015','Poorva Express','12303','Delhi','Varanasi','New Delhi Railway Station','Varanasi Junction','["Kanpur Central","Prayagraj Junction"]','2025-06-10','16:00','07:25',925,600,1200,1800,NULL,NULL,NULL,200,160,60,0,0,0),
('T016','Mahananda Express','15609','Delhi','Varanasi','New Delhi Railway Station','Varanasi Junction','["Aligarh Junction","Kanpur Central","Prayagraj Junction"]','2025-06-10','11:55','05:55',1080,500,1000,1550,NULL,NULL,NULL,220,180,70,0,0,0),
('T017','Vibhuti Express','14235','Delhi','Varanasi','New Delhi Railway Station','Varanasi Junction','["Aligarh Junction","Kanpur Central","Prayagraj Junction","Mirzapur Station"]','2025-06-10','07:30','01:05',1055,450,900,1380,NULL,NULL,NULL,220,180,70,0,0,0),
('T018','Saptkranti Express','12557','Delhi','Varanasi','New Delhi Railway Station','Varanasi Junction','["Prayagraj Junction"]','2025-06-10','16:30','05:30',780,NULL,NULL,NULL,NULL,1100,1500,0,0,0,0,80,35),
-- MUMBAI → GOA (6 trains)
('T019','Tejas Express','22119','Mumbai','Goa','CSMT Mumbai','Madgaon Junction','["Ratnagiri Station","Kankavli Station"]','2025-06-10','05:00','14:00',540,NULL,NULL,NULL,NULL,1500,2200,0,0,0,0,100,40),
('T020','Konkan Kanya Express','10111','Mumbai','Goa','CSMT Mumbai','Madgaon Junction','["Roha Station","Ratnagiri Station","Kudal Station","Sawantwadi Road"]','2025-06-10','23:05','10:55',710,650,1350,1950,NULL,NULL,NULL,180,120,40,0,0,0),
('T021','Mandovi Express','10103','Mumbai','Goa','CSMT Mumbai','Madgaon Junction','["Thane Station","Panvel Station","Roha Station","Ratnagiri Station","Sawantwadi Road"]','2025-06-10','07:10','20:20',790,600,1250,1850,NULL,NULL,NULL,200,140,50,0,0,0),
('T022','Jan Shatabdi Express','12051','Mumbai','Goa','CSMT Mumbai','Madgaon Junction','["Khed Station","Ratnagiri Station","Kudal Station"]','2025-06-10','05:20','14:00',520,NULL,NULL,NULL,NULL,1100,NULL,0,0,0,0,120,0),
('T023','Netravati Express','16345','Mumbai','Goa','CSMT Mumbai','Madgaon Junction','["Ratnagiri Station","Kudal Station","Sawantwadi Road"]','2025-06-10','11:50','23:00',670,580,1150,1750,NULL,NULL,NULL,200,160,60,0,0,0),
('T024','Goa Express','12779','Mumbai','Goa','CSMT Mumbai','Vasco da Gama Station','["Thane Station","Panvel Station","Roha Station","Khed Station","Ratnagiri Station","Sawantwadi Road"]','2025-06-10','12:00','02:00',840,520,1050,1600,NULL,NULL,NULL,220,170,65,0,0,0),
-- CHENNAI → BANGALORE (6 trains)
('T025','Shatabdi Express','12007','Chennai','Bangalore','Chennai Central Station','KSR Bengaluru City Junction','[]','2025-06-10','06:00','10:55',295,NULL,NULL,NULL,NULL,880,1300,0,0,0,0,100,40),
('T026','Brindavan Express','12639','Chennai','Bangalore','Chennai Central Station','KSR Bengaluru City Junction','["Vellore Katpadi Junction","Jolarpettai Junction","Krishnagiri Station"]','2025-06-10','07:40','12:35',295,NULL,NULL,NULL,NULL,550,NULL,0,0,0,0,160,0),
('T027','Intercity SF Express','12677','Chennai','Bangalore','Chennai Central Station','KSR Bengaluru City Junction','["Ambur Station","Krishnagiri Station","Hosur Station"]','2025-06-10','08:35','14:10',335,380,780,NULL,NULL,NULL,NULL,180,140,0,0,0,0),
('T028','Lalbagh Express','12608','Chennai','Bangalore','Chennai Egmore Station','KSR Bengaluru City Junction','["Vellore Katpadi Junction","Krishnagiri Station","Hosur Station"]','2025-06-10','16:50','22:10',320,350,720,1100,NULL,NULL,NULL,180,140,50,0,0,0),
('T029','Island Express','16341','Chennai','Bangalore','Chennai Central Station','KSR Bengaluru City Junction','["Vellore Katpadi Junction","Jolarpettai Junction","Krishnagiri Station"]','2025-06-10','19:15','00:30',315,320,680,1050,NULL,NULL,NULL,200,160,60,0,0,0),
('T030','Kaveri Express','12677','Chennai','Bangalore','Chennai Egmore Station','KSR Bengaluru City Junction','["Arakkonam Junction","Vellore Katpadi Junction","Jolarpettai Junction"]','2025-06-10','14:00','19:30',330,340,700,1080,NULL,NULL,NULL,190,150,55,0,0,0),
-- DELHI → JAIPUR (5 trains)
('T031','Ajmer Shatabdi','12015','Delhi','Jaipur','New Delhi Railway Station','Jaipur Junction','["Gurgaon Station"]','2025-06-10','06:05','09:15',190,NULL,NULL,NULL,NULL,700,1050,0,0,0,0,100,40),
('T032','Double Decker Express','12985','Delhi','Jaipur','New Delhi Railway Station','Jaipur Junction','["Gurgaon Station","Rewari Junction"]','2025-06-10','06:05','10:35',270,NULL,NULL,NULL,NULL,650,NULL,0,0,0,0,120,0),
('T033','Jaipur SF Express','12413','Delhi','Jaipur','New Delhi Railway Station','Jaipur Junction','["Gurgaon Station","Rewari Junction","Alwar Junction"]','2025-06-10','18:00','23:30',330,380,750,1150,NULL,NULL,NULL,150,120,50,0,0,0),
('T034','Pink City Express','12017','Delhi','Jaipur','New Delhi Railway Station','Jaipur Junction','["Rewari Junction"]','2025-06-10','21:45','02:25',280,320,680,1050,NULL,NULL,NULL,160,130,50,0,0,0),
('T035','Intercity Express','12016','Delhi','Jaipur','New Delhi Railway Station','Jaipur Junction','["Mathura Junction","Alwar Junction"]','2025-06-10','15:00','20:40',340,350,700,NULL,NULL,NULL,NULL,180,140,0,0,0,0),
-- DELHI → KOLKATA (5 trains)
('T036','Rajdhani Express','12301','Delhi','Kolkata','New Delhi Railway Station','Howrah Junction','["Kanpur Central","Prayagraj Junction","Gaya Junction","Dhanbad Junction"]','2025-06-10','16:55','09:55',1020,NULL,2100,2900,4800,NULL,NULL,0,180,100,30,0,0),
('T037','Poorva Express','12303','Delhi','Kolkata','New Delhi Railway Station','Howrah Junction','["Kanpur Central","Prayagraj Junction","Gaya Junction"]','2025-06-10','08:00','06:30',1350,750,1500,2200,NULL,NULL,NULL,180,140,50,0,0,0),
('T038','Durgiana Express','12317','Delhi','Kolkata','New Delhi Railway Station','Howrah Junction','["Kanpur Central","Prayagraj Junction","Asansol Junction"]','2025-06-10','21:35','22:20',1485,680,1350,2000,NULL,NULL,NULL,200,160,60,0,0,0),
('T039','Howrah Mail','12311','Delhi','Kolkata','New Delhi Railway Station','Howrah Junction','["Aligarh Junction","Kanpur Central","Prayagraj Junction","Gaya Junction"]','2025-06-10','19:05','23:30',1705,620,1250,1900,NULL,NULL,NULL,220,180,70,0,0,0),
('T040','Kalka Mail','12311','Delhi','Kolkata','New Delhi Railway Station','Howrah Junction','["Kanpur Central","Prayagraj Junction","Asansol Junction","Kharagpur Junction"]','2025-06-10','07:00','13:00',1440,600,1200,1800,NULL,NULL,NULL,220,180,70,0,0,0);

-- ============================================================
-- BUSES (6+ per route, all types, proper bus stands)
-- ============================================================
INSERT INTO buses VALUES
-- DELHI → JAIPUR (8 buses)
('B001','RedBus Volvo','Delhi','Jaipur','Kashmere Gate ISBT, Delhi','Sindhi Camp Bus Stand, Jaipur','["Gurgaon Sector 14 Bus Stop","Manesar Bus Stop","Behror Bus Stop"]','2025-06-10','06:00','11:30',330,'Volvo AC',899,36),
('B002','RSRTC Deluxe','Delhi','Jaipur','Kashmere Gate ISBT, Delhi','Sindhi Camp Bus Stand, Jaipur','["Gurgaon Bus Stand","Rewari Bus Stand","Shahjahanpur Bus Stop"]','2025-06-10','07:30','13:15',345,'AC Seater',549,45),
('B003','Neeta Travels','Delhi','Jaipur','Sarai Kale Khan Bus Stand, Delhi','Sindhi Camp Bus Stand, Jaipur','["Behror Bus Stop","Shahjahanpur Bus Stop"]','2025-06-10','10:00','15:00',300,'AC Sleeper',799,32),
('B004','RSRTC Express','Delhi','Jaipur','Kashmere Gate ISBT, Delhi','Sindhi Camp Bus Stand, Jaipur','["Rewari Bus Stand","Alwar Bus Stand"]','2025-06-10','12:30','18:00',330,'Non-AC Seater',299,55),
('B005','Orange Travels','Delhi','Jaipur','Sarai Kale Khan Bus Stand, Delhi','Sindhi Camp Bus Stand, Jaipur','["Manesar Bus Stop","Behror Bus Stop"]','2025-06-10','14:00','19:30',330,'Luxury Sleeper',1199,24),
('B006','Hans Travels','Delhi','Jaipur','Kashmere Gate ISBT, Delhi','Sindhi Camp Bus Stand, Jaipur','["Behror Bus Stop"]','2025-06-10','16:00','21:00',300,'Volvo AC',849,36),
('B007','SRS Travels','Delhi','Jaipur','Sarai Kale Khan Bus Stand, Delhi','Sindhi Camp Bus Stand, Jaipur','["Gurgaon Bus Stand","Rewari Bus Stand"]','2025-06-10','20:00','01:30',330,'AC Seater',599,44),
('B008','KGN Travels','Delhi','Jaipur','Kashmere Gate ISBT, Delhi','Sindhi Camp Bus Stand, Jaipur','["Rewari Bus Stand","Behror Bus Stop","Shahjahanpur Bus Stop"]','2025-06-10','22:30','04:00',330,'Non-AC Sleeper',349,44),
-- MUMBAI → PUNE (6 buses)
('B009','MSRTC Shivneri','Mumbai','Pune','Dadar Bus Depot, Mumbai','Shivajinagar Bus Stand, Pune','[]','2025-06-10','06:00','08:45',165,'Volvo AC',599,45),
('B010','Orange Travels','Mumbai','Pune','Dadar Bus Depot, Mumbai','Shivajinagar Bus Stand, Pune','["Khopoli Bus Stop","Khalapur Bus Stop"]','2025-06-10','08:30','11:30',180,'AC Seater',499,45),
('B011','Neeta Travels','Mumbai','Pune','Dadar Bus Depot, Mumbai','Shivajinagar Bus Stand, Pune','["Khopoli Bus Stop","Khalapur Bus Stop"]','2025-06-10','11:00','14:00',180,'Luxury Sleeper',899,24),
('B012','SRS Volvo','Mumbai','Pune','Dadar Bus Depot, Mumbai','Shivajinagar Bus Stand, Pune','["Khopoli Bus Stop"]','2025-06-10','14:30','17:30',180,'Volvo AC',699,40),
('B013','MSRTC Express','Mumbai','Pune','CST Bus Stand, Mumbai','Shivajinagar Bus Stand, Pune','["Khalapur Bus Stop"]','2025-06-10','18:00','21:30',210,'Non-AC Seater',199,60),
('B014','IntrCity Smart','Mumbai','Pune','Dadar Bus Depot, Mumbai','Shivajinagar Bus Stand, Pune','[]','2025-06-10','22:00','00:45',165,'AC Sleeper',799,28),
-- BANGALORE → GOA (7 buses)
('B015','VRL Luxury','Bangalore','Goa','Majestic Bus Terminal, Bangalore','Panaji Bus Stand, Goa','["Hubli Bus Stand","Dharwad Bus Stand","Belgaum Bus Stand"]','2025-06-10','20:00','06:00',600,'Luxury Sleeper',1599,28),
('B016','KSRTC Airavat','Bangalore','Goa','Majestic Bus Terminal, Bangalore','Panaji Bus Stand, Goa','["Dharwad Bus Stand","Belgaum Bus Stand"]','2025-06-10','20:30','06:30',600,'Volvo AC',1299,45),
('B017','Paulo Travels','Bangalore','Goa','Majestic Bus Terminal, Bangalore','Panaji Bus Stand, Goa','["Hubli Bus Stand","Belgaum Bus Stand"]','2025-06-10','19:00','05:00',600,'AC Sleeper',1099,32),
('B018','Parveen Travels','Bangalore','Goa','Majestic Bus Terminal, Bangalore','Panaji Bus Stand, Goa','["Hubli Bus Stand","Dharwad Bus Stand","Belgaum Bus Stand","Londa Junction"]','2025-06-10','18:00','05:00',660,'AC Sleeper',999,36),
('B019','KPN Travels','Bangalore','Goa','Majestic Bus Terminal, Bangalore','Panaji Bus Stand, Goa','["Hubli Bus Stand","Dharwad Bus Stand","Belgaum Bus Stand"]','2025-06-10','22:00','08:00',600,'Volvo AC',1199,36),
('B020','KSRTC Express','Bangalore','Goa','Majestic Bus Terminal, Bangalore','Panaji Bus Stand, Goa','["Dharwad Bus Stand","Belgaum Bus Stand"]','2025-06-10','22:30','08:30',600,'Non-AC Seater',649,55),
('B021','IntrCity Smart','Bangalore','Goa','Majestic Bus Terminal, Bangalore','Panaji Bus Stand, Goa','["Hubli Bus Stand","Belgaum Bus Stand"]','2025-06-10','19:30','05:30',600,'Volvo AC',1399,36),
-- CHENNAI → BANGALORE (7 buses)
('B022','KSRTC Airavat','Chennai','Bangalore','CMBT Bus Stand, Chennai','Majestic Bus Terminal, Bangalore','["Krishnagiri Bus Stand","Hosur Bus Stop"]','2025-06-10','22:00','06:00',480,'Volvo AC',899,45),
('B023','Orange Travels','Chennai','Bangalore','CMBT Bus Stand, Chennai','Majestic Bus Terminal, Bangalore','["Krishnagiri Bus Stand","Hosur Bus Stop"]','2025-06-10','21:00','05:30',510,'AC Sleeper',799,32),
('B024','SRS Travels','Chennai','Bangalore','CMBT Bus Stand, Chennai','Majestic Bus Terminal, Bangalore','["Krishnagiri Bus Stand"]','2025-06-10','20:00','04:00',480,'Luxury Sleeper',1199,24),
('B025','TNSTC Deluxe','Chennai','Bangalore','CMBT Bus Stand, Chennai','Majestic Bus Terminal, Bangalore','["Krishnagiri Bus Stand","Hosur Bus Stop","Electronic City Bus Stop"]','2025-06-10','23:00','07:30',510,'Non-AC Seater',399,60),
('B026','KPN Travels','Chennai','Bangalore','CMBT Bus Stand, Chennai','Majestic Bus Terminal, Bangalore','["Krishnagiri Bus Stand","Hosur Bus Stop"]','2025-06-10','21:30','05:30',480,'Volvo AC',849,36),
('B027','IntrCity Smart','Chennai','Bangalore','CMBT Bus Stand, Chennai','Majestic Bus Terminal, Bangalore','["Krishnagiri Bus Stand"]','2025-06-10','23:30','07:30',480,'Luxury Sleeper',1099,28),
('B028','Parveen Travels','Chennai','Bangalore','CMBT Bus Stand, Chennai','Majestic Bus Terminal, Bangalore','["Vellore Bus Stand","Krishnagiri Bus Stand","Hosur Bus Stop"]','2025-06-10','20:30','06:00',570,'AC Sleeper',749,32),
-- DELHI → DEHRADUN (6 buses)
('B029','UPSRTC Volvo','Delhi','Dehradun','Kashmere Gate ISBT, Delhi','Dehradun ISBT, Dehradun','["Meerut Bus Stand","Muzaffarnagar Bus Stop","Roorkee Bus Stand","Haridwar Bus Stand"]','2025-06-10','06:00','11:00',300,'Volvo AC',699,36),
('B030','Himalayan Travels','Delhi','Dehradun','Kashmere Gate ISBT, Delhi','Dehradun ISBT, Dehradun','["Muzaffarnagar Bus Stop","Roorkee Bus Stand","Haridwar Bus Stand"]','2025-06-10','08:00','13:30',330,'AC Sleeper',599,32),
('B031','GMOU Bus','Delhi','Dehradun','Kashmere Gate ISBT, Delhi','Dehradun ISBT, Dehradun','["Haridwar Bus Stand"]','2025-06-10','10:30','16:00',330,'Non-AC Seater',349,55),
('B032','Orange Travels','Delhi','Dehradun','Sarai Kale Khan, Delhi','Dehradun ISBT, Dehradun','["Meerut Bus Stand","Haridwar Bus Stand","Rishikesh Bus Stand"]','2025-06-10','14:00','20:00',360,'AC Seater',499,44),
('B033','RedBus Premium','Delhi','Dehradun','Kashmere Gate ISBT, Delhi','Dehradun ISBT, Dehradun','["Haridwar Bus Stand"]','2025-06-10','22:00','03:30',330,'Luxury Sleeper',999,24),
('B034','Neeta Travels','Delhi','Dehradun','Sarai Kale Khan, Delhi','Dehradun ISBT, Dehradun','["Muzaffarnagar Bus Stop","Roorkee Bus Stand","Haridwar Bus Stand"]','2025-06-10','23:30','05:00',330,'Volvo AC',749,36),
-- MUMBAI → GOA (6 buses)
('B035','Paulo Travels','Mumbai','Goa','Dadar Bus Depot, Mumbai','Panaji Bus Stand, Goa','["Ratnagiri Bus Stand","Sawantwadi Bus Stand"]','2025-06-10','20:00','07:00',660,'AC Sleeper',1299,32),
('B036','VRL Travels','Mumbai','Goa','Dadar Bus Depot, Mumbai','Panaji Bus Stand, Goa','["Ratnagiri Bus Stand"]','2025-06-10','21:00','08:00',660,'Luxury Sleeper',1599,24),
('B037','Sai Travels','Mumbai','Goa','CST Bus Stand, Mumbai','Panaji Bus Stand, Goa','["Ratnagiri Bus Stand","Kudal Bus Stop","Sawantwadi Bus Stand"]','2025-06-10','19:00','07:30',750,'Non-AC Sleeper',799,40),
('B038','MSRTC Shivshahi','Mumbai','Goa','Dadar Bus Depot, Mumbai','Panaji Bus Stand, Goa','["Ratnagiri Bus Stand","Kankavli Bus Stop"]','2025-06-10','18:00','06:00',720,'Volvo AC',1099,45),
('B039','KPN Travels','Mumbai','Goa','CST Bus Stand, Mumbai','Panaji Bus Stand, Goa','["Ratnagiri Bus Stand","Sawantwadi Bus Stand"]','2025-06-10','22:00','09:30',690,'AC Seater',949,44),
('B040','Orange Travels','Mumbai','Goa','Dadar Bus Depot, Mumbai','Panaji Bus Stand, Goa','["Ratnagiri Bus Stand","Kudal Bus Stop"]','2025-06-10','17:00','05:00',720,'AC Sleeper',1199,32);

-- ROUTE GRAPH
INSERT INTO route_graph (city_from,city_to,from_lat,from_lng,to_lat,to_lng,distance_km,base_price,transport_type,duration_mins) VALUES
('Delhi','Mumbai',28.6139,77.2090,19.0760,72.8777,1400,3499,'flight',145),
('Delhi','Goa',28.6139,77.2090,15.4909,73.8278,1900,5299,'flight',155),
('Delhi','Bangalore',28.6139,77.2090,12.9716,77.5946,2100,5499,'flight',165),
('Delhi','Chennai',28.6139,77.2090,13.0827,80.2707,2200,4199,'flight',175),
('Delhi','Kolkata',28.6139,77.2090,22.5726,88.3639,1500,3799,'flight',155),
('Delhi','Hyderabad',28.6139,77.2090,17.3850,78.4867,1500,3999,'flight',145),
('Delhi','Jaipur',28.6139,77.2090,26.9124,75.7873,280,2499,'flight',60),
('Mumbai','Goa',19.0760,72.8777,15.4909,73.8278,600,2999,'flight',75),
('Mumbai','Bangalore',19.0760,72.8777,12.9716,77.5946,1000,3299,'flight',110),
('Mumbai','Chennai',19.0760,72.8777,13.0827,80.2707,1350,3799,'flight',125),
('Bangalore','Chennai',12.9716,77.5946,13.0827,80.2707,350,2499,'flight',60),
('Hyderabad','Delhi',17.3850,78.4867,28.6139,77.2090,1500,3999,'flight',145),
('Hyderabad','Mumbai',17.3850,78.4867,19.0760,72.8777,700,2999,'flight',90),
('Delhi','Mumbai',28.6139,77.2090,19.0760,72.8777,1400,1850,'train',915),
('Delhi','Agra',28.6139,77.2090,27.1767,78.0081,200,750,'train',130),
('Delhi','Jaipur',28.6139,77.2090,26.9124,75.7873,280,600,'train',190),
('Delhi','Varanasi',28.6139,77.2090,25.3176,82.9739,800,1200,'train',480),
('Delhi','Kolkata',28.6139,77.2090,22.5726,88.3639,1500,2100,'train',1020),
('Mumbai','Goa',19.0760,72.8777,15.4909,73.8278,600,1500,'train',540),
('Mumbai','Pune',19.0760,72.8777,18.5204,73.8567,150,350,'train',180),
('Chennai','Bangalore',13.0827,80.2707,12.9716,77.5946,350,550,'train',295),
('Delhi','Jaipur',28.6139,77.2090,26.9124,75.7873,280,599,'bus',330),
('Mumbai','Pune',19.0760,72.8777,18.5204,73.8567,150,499,'bus',180),
('Bangalore','Goa',12.9716,77.5946,15.4909,73.8278,570,1099,'bus',600),
('Chennai','Bangalore',13.0827,80.2707,12.9716,77.5946,350,799,'bus',480),
('Mumbai','Goa',19.0760,72.8777,15.4909,73.8278,600,1299,'bus',720),
('Delhi','Dehradun',28.6139,77.2090,30.3165,78.0322,280,599,'bus',300);

INSERT INTO route_graph (city_from,city_to,from_lat,from_lng,to_lat,to_lng,distance_km,base_price,transport_type,duration_mins)
SELECT city_to,city_from,to_lat,to_lng,from_lat,from_lng,distance_km,base_price,transport_type,duration_mins FROM route_graph;

-- SEATS
INSERT INTO seats (transport_id,transport_type,travel_class,seat_number,seat_category) VALUES
('F001','flight','Economy','1A','disability'),('F001','flight','Economy','1B','disability'),
('F001','flight','Economy','2A','senior'),('F001','flight','Economy','2B','senior'),('F001','flight','Economy','2C','senior'),
('F001','flight','Economy','3A','female'),('F001','flight','Economy','3B','female'),('F001','flight','Economy','3C','female'),('F001','flight','Economy','3D','female'),
('F001','flight','Economy','4A','general'),('F001','flight','Economy','4B','general'),('F001','flight','Economy','4C','general'),
('F001','flight','Economy','5A','general'),('F001','flight','Economy','5B','general'),('F001','flight','Economy','5C','general'),
('F002','flight','Business','1A','disability'),('F002','flight','Business','2A','senior'),('F002','flight','Business','3A','female'),('F002','flight','Business','4A','general'),
('T001','train','3AC','1A','disability'),('T001','train','3AC','1B','disability'),
('T001','train','3AC','2A','senior'),('T001','train','3AC','2B','senior'),('T001','train','3AC','2C','senior'),
('T001','train','3AC','3A','female'),('T001','train','3AC','3B','female'),('T001','train','3AC','3C','female'),
('T001','train','3AC','4A','general'),('T001','train','3AC','4B','general'),('T001','train','3AC','4C','general'),
('B001','bus','Volvo AC','L1','disability'),('B001','bus','Volvo AC','L2','female'),('B001','bus','Volvo AC','L3','female'),
('B001','bus','Volvo AC','U1','senior'),('B001','bus','Volvo AC','U2','general'),('B001','bus','Volvo AC','U3','general');
