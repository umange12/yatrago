const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'yatrago_dsa_2025';

app.use(cors({ origin: '*', credentials: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, '../frontend')));

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || '',
  database: process.env.DB_NAME || 'yatragodb',
  waitForConnections: true,
  connectionLimit: 10,
});

(async () => {
  try {
    const conn = await pool.getConnection();
    console.log('✅ MySQL Connected!');
    conn.release();
  } catch (err) {
    console.error('❌ DB Failed:', err.message);
  }
})();

// ============================================================
// DSA 1: MIN-HEAP (Priority Queue)
// Used: Seat assignment + Booking waitlist
// ============================================================
class MinHeap {
  constructor() { this.heap = []; }
  _p(i) { return Math.floor((i-1)/2); }
  _l(i) { return 2*i+1; }
  _r(i) { return 2*i+2; }
  _swap(i,j) { [this.heap[i],this.heap[j]]=[this.heap[j],this.heap[i]]; }

  insert(item) {
    this.heap.push(item);
    let i = this.heap.length - 1;
    while (i > 0 && this.heap[this._p(i)].priority > this.heap[i].priority) {
      this._swap(i, this._p(i)); i = this._p(i);
    }
  }

  extractMin() {
    if (!this.heap.length) return null;
    if (this.heap.length === 1) return this.heap.pop();
    const min = this.heap[0];
    this.heap[0] = this.heap.pop();
    let i = 0;
    while (true) {
      let s = i, l = this._l(i), r = this._r(i);
      if (l < this.heap.length && this.heap[l].priority < this.heap[s].priority) s = l;
      if (r < this.heap.length && this.heap[r].priority < this.heap[s].priority) s = r;
      if (s === i) break;
      this._swap(i, s); i = s;
    }
    return min;
  }
  size() { return this.heap.length; }
  isEmpty() { return !this.heap.length; }
  toArray() { return [...this.heap].sort((a,b)=>a.priority-b.priority); }
}

// Priority: disability=1 (highest), women40plus=2, senior60plus=3, general=4
function computePriority(p) {
  if (p.disability) return 1;
  if (p.gender==='female' && parseInt(p.age)>=40) return 2;
  if (parseInt(p.age)>=60) return 3;
  return 4;
}
function priorityLabel(score) {
  if (score===1) return '♿ Disability — Highest Priority';
  if (score===2) return '👩 Women 40+ — Priority 2';
  if (score===3) return '👴 Senior 60+ — Priority 3';
  return '👤 General — Standard';
}

// ============================================================
// DSA 2: GRAPH + DIJKSTRA'S ALGORITHM
// Used: Cheapest/fastest city route finder
// ============================================================
class Graph {
  constructor() { this.adj = new Map(); }
  addEdge(from, to, weight, meta={}) {
    if (!this.adj.has(from)) this.adj.set(from,[]);
    this.adj.get(from).push({ node:to, weight, ...meta });
  }
  dijkstra(src, tgt) {
    const dist = new Map(), prev = new Map(), edgeUsed = new Map();
    for (const c of this.adj.keys()) dist.set(c, Infinity);
    dist.set(src, 0);
    const pq = new MinHeap();
    pq.insert({ priority:0, node:src });
    const visited = new Set();
    while (!pq.isEmpty()) {
      const { node:u } = pq.extractMin();
      if (visited.has(u)) continue;
      visited.add(u);
      if (u === tgt) break;
      for (const e of (this.adj.get(u)||[])) {
        const alt = dist.get(u) + e.weight;
        if (alt < (dist.get(e.node)??Infinity)) {
          dist.set(e.node, alt);
          prev.set(e.node, u);
          edgeUsed.set(e.node, e);
          pq.insert({ priority:alt, node:e.node });
        }
      }
    }
    const path=[], edges=[];
    let cur = tgt;
    while (cur) { path.unshift(cur); if(edgeUsed.has(cur)) edges.unshift(edgeUsed.get(cur)); cur=prev.get(cur)||null; }
    return { cost: dist.get(tgt)??Infinity, path, edges, reachable: (dist.get(tgt)??Infinity)<Infinity };
  }
}

// ============================================================
// DSA 3: STACK (LIFO) — Search History last 10
// ============================================================
class SearchStack {
  constructor(max=10) { this.stack=[]; this.max=max; }
  push(item) {
    this.stack = this.stack.filter(s=>!(s.from===item.from&&s.to===item.to&&s.type===item.type));
    this.stack.push(item);
    if (this.stack.length>this.max) this.stack.shift();
  }
  toArray() { return [...this.stack].reverse(); }
  size() { return this.stack.length; }
}
const userStacks = new Map();
const getStack = id => { if(!userStacks.has(id)) userStacks.set(id,new SearchStack()); return userStacks.get(id); };

// ============================================================
// DSA 4: BOOKING QUEUE (Priority Queue Waitlist)
// ============================================================
class BookingQueue {
  constructor() { this.heap = new MinHeap(); }
  enqueue(b) { this.heap.insert(b); }
  dequeue() { return this.heap.extractMin(); }
  toArray() { return this.heap.toArray(); }
  size() { return this.heap.size(); }
}
const queues = new Map();
const getQueue = id => { if(!queues.has(id)) queues.set(id,new BookingQueue()); return queues.get(id); };

// ============================================================
// DSA 5: HASH MAP — City autocomplete
// ============================================================
class CityHashMap {
  constructor() { this.map=new Map(); this.prefix=new Map(); }
  insert(city) {
    this.map.set(city.toLowerCase(), city);
    for (let i=1;i<=city.length;i++) {
      const k=city.toLowerCase().slice(0,i);
      if(!this.prefix.has(k)) this.prefix.set(k,[]);
      if(!this.prefix.get(k).includes(city)) this.prefix.get(k).push(city);
    }
  }
  autocomplete(q) { return this.prefix.get(q.toLowerCase().trim())||[]; }
  lookup(q) { return this.map.get(q.toLowerCase().trim())||null; }
}
const cityMap = new CityHashMap();
['Delhi','Mumbai','Bangalore','Chennai','Kolkata','Goa','Pune','Agra','Jaipur','Varanasi',
 'Hyderabad','Ahmedabad','Surat','Lucknow','Chandigarh','Bhopal','Indore','Patna','Kochi','Nagpur',
 'Bhubaneswar','Ranchi','Guwahati','Amritsar','Ludhiana','Jodhpur','Udaipur','Ajmer','Kota','Bikaner',
 'Dehradun','Haridwar','Rishikesh','Shimla','Manali','Srinagar','Leh','Jammu','Pathankot','Dharamsala',
 'Coimbatore','Madurai','Thiruvananthapuram','Mangalore','Mysore','Hubli','Belgaum','Dharwad',
 'Vijayawada','Visakhapatnam','Tirupati','Nellore','Guntur','Kakinada','Rajahmundry','Warangal',
 'Nashik','Aurangabad','Kolhapur','Solapur','Sangli','Satara','Latur','Jalgaon','Dhule','Amravati',
 'Meerut','Ghaziabad','Noida','Faridabad','Gurugram','Rohtak','Panipat','Sonipat','Karnal','Ambala',
 'Allahabad','Kanpur','Gorakhpur','Moradabad','Aligarh','Mathura','Vrindavan','Ayodhya','Bareilly',
 'Jabalpur','Gwalior','Ujjain','Ratlam','Sagar','Satna','Rewa','Bhilai','Bilaspur','Raipur',
 'Bokaro','Dhanbad','Jamshedpur','Durgapur','Asansol','Siliguri','Darjeeling','Malda','Murshidabad',
 'Cuttack','Puri','Rourkela','Sambalpur','Berhampur','Brahmapur','Paradip','Bhadrak',
 'Pondicherry','Salem','Trichy','Vellore','Erode','Tirunelveli','Tuticorin','Thanjavur',
 'Calicut','Thrissur','Palakkad','Kannur','Alappuzha','Kollam','Idukki',
 'Jammu','Kathua','Udhampur','Anantnag','Baramulla','Sopore','Kupwara',
 'Itanagar','Dibrugarh','Tezpur','Jorhat','Nagaon','Silchar','Karimganj',
 'Imphal','Aizawl','Shillong','Agartala','Kohima','Gangtok','Pelling',
 'Rajkot','Vadodara','Surat','Jamnagar','Bhavnagar','Anand','Mehsana',
 'Prayagraj','Mirzapur','Jhansi','Banda','Chitrakoot','Lalitpur',
 'Darbhanga','Muzaffarpur','Bhagalpur','Gaya','Sasaram','Arrah',
 'Madurai','Tiruppur','Ooty','Kodaikanal','Kumbakonam','Nagapattinam',
 'Ratnagiri','Sawantwadi','Kudal','Londa','Hubli','Karwar',
 'Hassan','Tumkur','Davangere','Shivamogga','Chikmagalur','Kodagu'
].forEach(c => cityMap.insert(c));

// ============================================================
// DSA 6: MERGE SORT — Sort results
// ============================================================
function mergeSort(arr, fn) {
  if (arr.length<=1) return arr;
  const m = Math.floor(arr.length/2);
  const L = mergeSort(arr.slice(0,m),fn);
  const R = mergeSort(arr.slice(m),fn);
  const res=[]; let i=0,j=0;
  while(i<L.length&&j<R.length) { res.push(fn(L[i],R[j])<=0?L[i++]:R[j++]); }
  return res.concat(L.slice(i)).concat(R.slice(j));
}

// ============================================================
// DSA 7: BINARY SEARCH — Price range filter
// ============================================================
function bsLower(arr, min, key='minPrice') {
  let lo=0,hi=arr.length;
  while(lo<hi){const m=(lo+hi)>>1; if(arr[m][key]<min)lo=m+1; else hi=m;}
  return lo;
}
function bsUpper(arr, max, key='minPrice') {
  let lo=0,hi=arr.length;
  while(lo<hi){const m=(lo+hi)>>1; if(arr[m][key]<=max)lo=m+1; else hi=m;}
  return lo;
}

// ============================================================
// DYNAMIC PRICING — Book early = cheap, last min = expensive
// ============================================================
function applyDynamicPrice(basePrice, departure, seatsLeft, totalSeats) {
  const now = new Date();
  const depTime = new Date();
  const [h,m] = departure.split(':').map(Number);
  depTime.setHours(h,m,0,0);
  const hoursLeft = (depTime - now) / 3600000;
  let multiplier = 1.0;
  if (hoursLeft < 2) multiplier = 2.2;       // last 2 hours
  else if (hoursLeft < 6) multiplier = 1.8;  // last 6 hours
  else if (hoursLeft < 12) multiplier = 1.4; // last 12 hours
  else if (hoursLeft < 24) multiplier = 1.2; // last 24 hours
  // Also increase if seats < 20%
  const seatRatio = seatsLeft / (totalSeats || 1);
  if (seatRatio < 0.1) multiplier *= 1.3;
  else if (seatRatio < 0.2) multiplier *= 1.15;
  return Math.round(basePrice * multiplier);
}

// ============================================================
// AUTH MIDDLEWARE
// ============================================================
function auth(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  try { req.user = jwt.verify(token, JWT_SECRET); next(); }
  catch { res.status(401).json({ error: 'Invalid token' }); }
}

// ============================================================
// AUTH ROUTES
// ============================================================
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { name, email, password, phone, age, gender, disability } = req.body;
    if (!name||!email||!password) return res.status(400).json({ error: 'All fields required' });
    const [ex] = await pool.query('SELECT id FROM users WHERE email=?',[email]);
    if (ex.length) return res.status(400).json({ error: 'Email already registered' });
    const hashed = await bcrypt.hash(password, 10);
    const id = uuidv4();
    await pool.query('INSERT INTO users(id,name,email,password,phone,age,gender,disability) VALUES(?,?,?,?,?,?,?,?)',
      [id,name,email,hashed,phone||'',age||25,gender||'other',disability?1:0]);
    const token = jwt.sign({id,email,name},JWT_SECRET,{expiresIn:'7d'});
    res.json({ token, user:{id,name,email,phone:phone||'',age,gender,disability} });
  } catch(e){ console.error(e); res.status(500).json({error:'Server error'}); }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const [rows] = await pool.query('SELECT * FROM users WHERE email=?',[email]);
    if (!rows.length) return res.status(400).json({error:'Invalid credentials'});
    const u = rows[0];
    if (!await bcrypt.compare(password, u.password)) return res.status(400).json({error:'Invalid credentials'});
    const token = jwt.sign({id:u.id,email:u.email,name:u.name},JWT_SECRET,{expiresIn:'7d'});
    res.json({ token, user:{id:u.id,name:u.name,email:u.email,phone:u.phone,age:u.age,gender:u.gender,disability:u.disability} });
  } catch(e){ res.status(500).json({error:'Server error'}); }
});

app.get('/api/auth/me', auth, async (req,res)=>{
  const [rows]=await pool.query('SELECT id,name,email,phone,age,gender,disability FROM users WHERE id=?',[req.user.id]);
  res.json(rows[0]||{});
});

// ============================================================
// CITY AUTOCOMPLETE (HashMap)
// ============================================================
app.get('/api/cities', (req,res)=>{
  const q = (req.query.q||'').trim();
  if (!q) return res.json([]);
  res.json(cityMap.autocomplete(q).slice(0,10));
});

// ============================================================
// FLIGHT SEARCH — MergeSort + BinarySearch + DynamicPricing
// ============================================================
app.get('/api/flights', async (req,res)=>{
  try {
    const { from, to, sort='price', minP, maxP, direct, userId } = req.query;
    let q='SELECT * FROM flights WHERE 1=1'; const params=[];
    if(from){q+=' AND `from` LIKE ?'; params.push(`%${from}%`);}
    if(to){q+=' AND `to` LIKE ?'; params.push(`%${to}%`);}
    if(direct==='1') q+=' AND is_direct=1';
    let [rows] = await pool.query(q, params);

    // Apply dynamic pricing + compute minPrice for each flight
    rows = rows.map(r => {
      const prices = [r.price_economy,r.price_business,r.price_first].filter(Boolean);
      const minBase = Math.min(...prices);
      const minPrice = applyDynamicPrice(minBase, r.departure, r.seats_economy||r.seats_business||50, 100);
      return { ...r, minPrice, dynamicPrices: {
        economy: r.price_economy ? applyDynamicPrice(r.price_economy,r.departure,r.seats_economy,120) : null,
        business: r.price_business ? applyDynamicPrice(r.price_business,r.departure,r.seats_business,28) : null,
        first: r.price_first ? applyDynamicPrice(r.price_first,r.departure,r.seats_first,8) : null,
      }, stops: r.stops ? JSON.parse(r.stops) : [] };
    });

    // DSA: Binary Search after Merge Sort
    if(minP||maxP){
      rows = mergeSort(rows,(a,b)=>a.minPrice-b.minPrice);
      const lo=bsLower(rows,parseInt(minP)||0,'minPrice');
      const hi=bsUpper(rows,parseInt(maxP)||999999,'minPrice');
      rows=rows.slice(lo,hi);
    }

    // DSA: Merge Sort
    if(sort==='price') rows=mergeSort(rows,(a,b)=>a.minPrice-b.minPrice);
    else if(sort==='price-desc') rows=mergeSort(rows,(a,b)=>b.minPrice-a.minPrice);
    else if(sort==='duration') rows=mergeSort(rows,(a,b)=>a.duration.localeCompare(b.duration));
    else if(sort==='departure') rows=mergeSort(rows,(a,b)=>a.departure.localeCompare(b.departure));
    else rows=mergeSort(rows,(a,b)=>a.minPrice-b.minPrice);

    // DSA: Stack push
    if(userId&&(from||to)){
      getStack(userId).push({from:from||'Any',to:to||'Any',type:'flights',time:new Date().toISOString()});
      try{await pool.query('INSERT INTO search_history(user_id,search_from,search_to,search_type) VALUES(?,?,?,?)',
        [userId,from||'Any',to||'Any','flights']);}catch(e){}
    }
    res.json(rows);
  }catch(e){ console.error(e); res.status(500).json({error:'Server error'}); }
});

// ============================================================
// TRAIN SEARCH
// ============================================================
app.get('/api/trains', async (req,res)=>{
  try {
    const { from, to, sort='price', minP, maxP, userId } = req.query;
    let q='SELECT * FROM trains WHERE 1=1'; const params=[];
    if(from){q+=' AND `from` LIKE ?'; params.push(`%${from}%`);}
    if(to){q+=' AND `to` LIKE ?'; params.push(`%${to}%`);}
    let [rows] = await pool.query(q, params);

    rows = rows.map(r => {
      const prices=[r.price_sleeper,r.price_3ac,r.price_2ac,r.price_1ac,r.price_cc,r.price_ec].filter(Boolean);
      const minBase = prices.length ? Math.min(...prices) : 999;
      const totalSeats = r.seats_sleeper+r.seats_3ac+r.seats_2ac+r.seats_1ac+r.seats_cc+r.seats_ec;
      const minPrice = applyDynamicPrice(minBase, r.departure, totalSeats, totalSeats+50);
      return { ...r, minPrice, dynamicPrices:{
        sleeper: r.price_sleeper?applyDynamicPrice(r.price_sleeper,r.departure,r.seats_sleeper,200):null,
        '3ac': r.price_3ac?applyDynamicPrice(r.price_3ac,r.departure,r.seats_3ac,180):null,
        '2ac': r.price_2ac?applyDynamicPrice(r.price_2ac,r.departure,r.seats_2ac,100):null,
        '1ac': r.price_1ac?applyDynamicPrice(r.price_1ac,r.departure,r.seats_1ac,40):null,
        cc: r.price_cc?applyDynamicPrice(r.price_cc,r.departure,r.seats_cc,120):null,
        ec: r.price_ec?applyDynamicPrice(r.price_ec,r.departure,r.seats_ec,80):null,
      }, stops: r.stops?JSON.parse(r.stops):[] };
    });

    if(minP||maxP){
      rows=mergeSort(rows,(a,b)=>a.minPrice-b.minPrice);
      rows=rows.slice(bsLower(rows,parseInt(minP)||0,'minPrice'),bsUpper(rows,parseInt(maxP)||999999,'minPrice'));
    }
    if(sort==='price') rows=mergeSort(rows,(a,b)=>a.minPrice-b.minPrice);
    else if(sort==='price-desc') rows=mergeSort(rows,(a,b)=>b.minPrice-a.minPrice);
    else if(sort==='duration') rows=mergeSort(rows,(a,b)=>a.duration.localeCompare(b.duration));
    else rows=mergeSort(rows,(a,b)=>a.minPrice-b.minPrice);

    if(userId&&(from||to)){
      getStack(userId).push({from:from||'Any',to:to||'Any',type:'trains',time:new Date().toISOString()});
      try{await pool.query('INSERT INTO search_history(user_id,search_from,search_to,search_type) VALUES(?,?,?,?)',
        [userId,from||'Any',to||'Any','trains']);}catch(e){}
    }
    res.json(rows);
  }catch(e){ console.error(e); res.status(500).json({error:'Server error'}); }
});

// ============================================================
// BUS SEARCH
// ============================================================
app.get('/api/buses', async (req,res)=>{
  try {
    const { from, to, sort='price', minP, maxP, busType, userId } = req.query;
    let q='SELECT * FROM buses WHERE 1=1'; const params=[];
    if(from){q+=' AND `from` LIKE ?'; params.push(`%${from}%`);}
    if(to){q+=' AND `to` LIKE ?'; params.push(`%${to}%`);}
    if(busType&&busType!=='all'){q+=' AND bus_type=?'; params.push(busType);}
    let [rows] = await pool.query(q, params);

    rows = rows.map(r => {
      const minPrice = applyDynamicPrice(r.price, r.departure, r.seats, r.seats+10);
      return { ...r, minPrice, stops: r.stops?JSON.parse(r.stops):[] };
    });

    if(minP||maxP){
      rows=mergeSort(rows,(a,b)=>a.minPrice-b.minPrice);
      rows=rows.slice(bsLower(rows,parseInt(minP)||0,'minPrice'),bsUpper(rows,parseInt(maxP)||999999,'minPrice'));
    }
    if(sort==='price') rows=mergeSort(rows,(a,b)=>a.minPrice-b.minPrice);
    else if(sort==='price-desc') rows=mergeSort(rows,(a,b)=>b.minPrice-a.minPrice);
    else if(sort==='duration') rows=mergeSort(rows,(a,b)=>a.duration.localeCompare(b.duration));
    else rows=mergeSort(rows,(a,b)=>a.minPrice-b.minPrice);

    if(userId&&(from||to)){
      getStack(userId).push({from:from||'Any',to:to||'Any',type:'buses',time:new Date().toISOString()});
      try{await pool.query('INSERT INTO search_history(user_id,search_from,search_to,search_type) VALUES(?,?,?,?)',
        [userId,from||'Any',to||'Any','buses']);}catch(e){}
    }
    res.json(rows);
  }catch(e){ console.error(e); res.status(500).json({error:'Server error'}); }
});

// ============================================================
// DIJKSTRA ROUTE FINDER
// ============================================================
app.get('/api/route/dijkstra', async (req,res)=>{
  try {
    const { from, to, opt='price' } = req.query;
    if(!from||!to) return res.status(400).json({error:'from and to required'});
    const [rows] = await pool.query('SELECT * FROM route_graph');
    const wKey = opt==='time'?'duration_mins':opt==='distance'?'distance_km':'base_price';

    const buildG = (filterFn) => {
      const g = new Graph();
      rows.filter(filterFn).forEach(r=>g.addEdge(r.city_from,r.city_to,r[wKey],
        {price:r.base_price,duration:r.duration_mins,transport:r.transport_type,distance:r.distance_km,stops:r.stops_count}));
      return g;
    };

    const allG=buildG(()=>true);
    const flG=buildG(r=>r.transport_type==='flight');
    const trG=buildG(r=>r.transport_type==='train');
    const buG=buildG(r=>r.transport_type==='bus');

    const cities=[...new Set(rows.map(r=>r.city_from))].sort();
    res.json({
      source:from, target:to, optimizedFor:opt,
      overall: allG.dijkstra(from,to),
      flight: flG.dijkstra(from,to),
      train: trG.dijkstra(from,to),
      bus: buG.dijkstra(from,to),
      cities, dsaNote:"Dijkstra's Algorithm + Min-Heap Priority Queue on Adjacency List Graph. O((V+E)logV)"
    });
  }catch(e){ console.error(e); res.status(500).json({error:'Server error'}); }
});

// ============================================================
// SEAT ASSIGNMENT (Priority Queue)
// ============================================================
async function assignSeat(tid, ttype, tclass, passenger) {
  const priority = computePriority(passenger);
  const catMap = {1:'disability',2:'female',3:'senior',4:'general'};
  const cats = [catMap[priority],'female','senior','general'];
  for (const cat of [...new Set(cats)]) {
    const [rows]=await pool.query(
      'SELECT * FROM seats WHERE transport_id=? AND transport_type=? AND travel_class=? AND seat_category=? AND is_reserved=0 ORDER BY seat_number LIMIT 1',
      [tid,ttype,tclass,cat]);
    if(rows.length) return rows[0];
  }
  const [any]=await pool.query(
    'SELECT * FROM seats WHERE transport_id=? AND transport_type=? AND is_reserved=0 LIMIT 1',
    [tid,ttype]);
  return any.length?any[0]:null;
}

// ============================================================
// BOOKING
// ============================================================
app.post('/api/bookings', auth, async (req,res)=>{
  try {
    const { type, itemId, passengers, travelClass, totalAmount, contactEmail, contactPhone } = req.body;
    const table = type==='flight'?'flights':type==='train'?'trains':'buses';
    const [items]=await pool.query(`SELECT * FROM \`${table}\` WHERE id=?`,[itemId]);
    if(!items.length) return res.status(404).json({error:'Not found'});

    const [uRows]=await pool.query('SELECT age,gender,disability FROM users WHERE id=?',[req.user.id]);
    const uProf=uRows[0]||{};
    const passenger={...passengers[0],...{
      gender:passengers[0].gender||uProf.gender,
      age:passengers[0].age||uProf.age,
      disability:passengers[0].disability||uProf.disability
    }};

    const priority=computePriority(passenger);
    const label=priorityLabel(priority);
    const seatRow=await assignSeat(itemId,type,travelClass||'Economy',passenger);
    const bookingId='BK'+uuidv4().slice(0,8).toUpperCase();

    if(seatRow){
      await pool.query('UPDATE seats SET is_reserved=1,booking_id=? WHERE id=?',[bookingId,seatRow.id]);
    }

    await pool.query(
      'INSERT INTO bookings(id,user_id,type,item_id,item_data,passengers,travel_class,total_amount,contact_email,contact_phone,seat_number,seat_category,priority_label) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)',
      [bookingId,req.user.id,type,itemId,JSON.stringify(items[0]),JSON.stringify(passengers),
       travelClass||'Economy',totalAmount,contactEmail,contactPhone,
       seatRow?.seat_number||null,seatRow?.seat_category||'general',label]);

    // Add to priority queue
    const pq=getQueue(itemId);
    pq.enqueue({priority,userId:req.user.id,name:passenger.name,bookingId,queuedAt:new Date()});

    res.json({
      id:bookingId, userId:req.user.id, type, item:items[0], passengers,
      travelClass, totalAmount, contactEmail, contactPhone,
      assignedSeat:seatRow?.seat_number||null,
      seatCategory:seatRow?.seat_category||'general',
      priorityScore:priority, priorityLabel:label,
      status:'Confirmed', bookedAt:new Date().toISOString(),
      dsaNote:`Priority Queue used. Score=${priority} → ${label}`
    });
  }catch(e){ console.error(e); res.status(500).json({error:'Booking failed'}); }
});

app.get('/api/bookings/my', auth, async (req,res)=>{
  const [rows]=await pool.query('SELECT * FROM bookings WHERE user_id=? ORDER BY booked_at DESC',[req.user.id]);
  res.json(rows.map(b=>({...b,item:JSON.parse(b.item_data),passengers:JSON.parse(b.passengers)})));
});

app.delete('/api/bookings/:id', auth, async (req,res)=>{
  await pool.query('UPDATE seats SET is_reserved=0,booking_id=NULL WHERE booking_id=?',[req.params.id]);
  const [r]=await pool.query("UPDATE bookings SET status='Cancelled' WHERE id=? AND user_id=?",[req.params.id,req.user.id]);
  if(!r.affectedRows) return res.status(404).json({error:'Not found'});
  res.json({success:true});
});

// ============================================================
// SEARCH HISTORY (Stack)
// ============================================================
app.get('/api/search-history', auth, async (req,res)=>{
  const stack=getStack(req.user.id);
  const [db]=await pool.query('SELECT * FROM search_history WHERE user_id=? ORDER BY searched_at DESC LIMIT 10',[req.user.id]);
  res.json({stack:stack.toArray(),db,size:stack.size(),dsaNote:'Stack (LIFO) — newest on top, max 10, duplicates removed'});
});

// ============================================================
// PRIORITY QUEUE — Booking Queue
// ============================================================
app.get('/api/queue/:id', (req,res)=>{
  const q=getQueue(req.params.id);
  res.json({id:req.params.id,size:q.size(),queue:q.toArray().map((e,i)=>({pos:i+1,...e}))});
});

// ============================================================
// DSA INFO
// ============================================================
app.get('/api/dsa', (_,res)=>res.json({
  project:'YatraGo v3 — DSA Travel Reservation',
  dsa:[
    {name:'Min-Heap Priority Queue',use:'Seat assignment + Booking waitlist',complexity:'O(log n)'},
    {name:"Dijkstra's Algorithm",use:'Shortest/cheapest city route',complexity:'O((V+E)log V)'},
    {name:'Graph Adjacency List',use:'City-to-city transport graph',complexity:'O(V+E)'},
    {name:'Stack LIFO',use:'Search history last 10',complexity:'O(1)'},
    {name:'Priority Queue Waitlist',use:'Disability>Women40+>Senior60+>General',complexity:'O(log n)'},
    {name:'Hash Map',use:'City autocomplete O(1)',complexity:'O(1)'},
    {name:'Merge Sort',use:'Sort results by price/duration',complexity:'O(n log n)'},
    {name:'Binary Search',use:'Price range filter',complexity:'O(log n)'},
    {name:'Dynamic Pricing',use:'Early bird cheap, last minute expensive',complexity:'O(1)'},
  ]
}));

app.get('*',(req,res)=>res.sendFile(path.join(__dirname,'../frontend/index.html')));

app.listen(PORT,()=>{
  console.log(`\n✈️  YatraGo v3 Server → http://localhost:${PORT}`);
  console.log(`📊 DSA Info → http://localhost:${PORT}/api/dsa\n`);
});

// ── CITIES FROM DB (HashMap loaded at startup) ──────────────
(async()=>{
  try{
    const [rows]=await pool.query('SELECT name,lat,lng FROM cities');
    rows.forEach(r=>cityMap.insert(r.name));
    console.log(`✅ Loaded ${rows.length} cities into HashMap`);
  }catch(e){console.log('Cities table loading skipped:',e.message);}
})();

// ── MULTI-PASSENGER BOOKING (override existing) ─────────────
app.post('/api/bookings/multi', async(req,res)=>{
  try{
    const{type,itemId,passengers,travelClass,contactEmail,contactPhone}=req.body;
    if(!passengers||!passengers.length) return res.status(400).json({error:'Add at least 1 passenger'});
    const table=type==='flight'?'flights':type==='train'?'trains':'buses';
    const[items]=await pool.query(`SELECT * FROM \`${table}\` WHERE id=?`,[itemId]);
    if(!items.length) return res.status(404).json({error:'Not found'});
    const item=items[0];

    // Compute price per class
    let pricePerPax=0;
    const cls=(travelClass||'Economy').toLowerCase().replace(' ','').replace('class','');
    if(type==='flight'){
      if(cls==='economy')pricePerPax=item.price_economy||item.price_economy;
      else if(cls==='business')pricePerPax=item.price_business;
      else if(cls==='first'||cls==='firstclass')pricePerPax=item.price_first;
      pricePerPax=pricePerPax||item.price_economy||3000;
    }else if(type==='train'){
      if(cls==='sleeper')pricePerPax=item.price_sleeper;
      else if(cls==='3ac')pricePerPax=item.price_3ac;
      else if(cls==='2ac')pricePerPax=item.price_2ac;
      else if(cls==='1ac')pricePerPax=item.price_1ac;
      else if(cls==='cc')pricePerPax=item.price_cc;
      else if(cls==='ec')pricePerPax=item.price_ec;
      pricePerPax=pricePerPax||item.price_sleeper||500;
    }else{
      pricePerPax=item.price||500;
    }

    // Apply dynamic pricing
    pricePerPax=applyDynamicPrice(pricePerPax,item.departure,item.seats||item.seats_economy||50,100);

    const totalAmount=pricePerPax*passengers.length;
    const bookingId='BK'+uuidv4().slice(0,8).toUpperCase();

    // Sort passengers by priority (Min-Heap)
    const heap=new MinHeap();
    passengers.forEach((p,idx)=>{
      const priority=computePriority(p);
      heap.insert({priority,idx,passenger:p});
    });

    // Assign seats to each passenger
    const seatAssignments=[];
    const priorityLabels=[];
    while(!heap.isEmpty()){
      const{passenger,priority}=heap.extractMin();
      const seatRow=await assignSeat(itemId,type,travelClass||'Economy',passenger);
      if(seatRow){
        await pool.query('UPDATE seats SET is_reserved=1,booking_id=? WHERE id=?',[bookingId,seatRow.id]);
        seatAssignments.push({name:passenger.name,seat:seatRow.seat_number,category:seatRow.seat_category});
      }
      priorityLabels.push({name:passenger.name,priority,label:priorityLabel(priority)});
    }

    await pool.query(
      'INSERT INTO bookings(id,user_id,type,item_id,item_data,travel_class,total_amount,contact_email,contact_phone,seat_assignments,priority_label) VALUES(?,?,?,?,?,?,?,?,?,?,?)',
      [bookingId,req.user.id,type,itemId,JSON.stringify(item),travelClass||'Economy',totalAmount,contactEmail,contactPhone,JSON.stringify(seatAssignments),priorityLabels[0]?.label||'General']
    );

    // Save each passenger
    for(const p of passengers){
      const priority=computePriority(p);
      const seat=seatAssignments.find(s=>s.name===p.name);
      await pool.query(
        'INSERT INTO booking_passengers(booking_id,passenger_name,age,gender,disability,seat_number,seat_category,priority_score) VALUES(?,?,?,?,?,?,?,?)',
        [bookingId,p.name,p.age||25,p.gender||'other',p.disability?1:0,seat?.seat||null,seat?.category||'general',priority]
      );
      // Add to priority queue
      getQueue(itemId).enqueue({priority,userId:req.user.id,name:p.name,bookingId,queuedAt:new Date()});
    }

    res.json({
      id:bookingId,type,item,passengers,travelClass,totalAmount,
      pricePerPax,passengerCount:passengers.length,
      contactEmail,contactPhone,seatAssignments,priorityLabels,
      status:'Confirmed',bookedAt:new Date().toISOString(),
      dsaNote:`Min-Heap sorted ${passengers.length} passengers by priority. Seats assigned: disability first → women 40+ → senior 60+ → general`
    });
  }catch(e){console.error(e);res.status(500).json({error:'Booking failed: '+e.message});}
});

// ── DIJKSTRA WITH MAP COORDINATES ───────────────────────────
app.get('/api/route/map', async(req,res)=>{
  try{
    const{from,to,opt='price'}=req.query;
    if(!from||!to) return res.status(400).json({error:'from and to required'});
    const[rows]=await pool.query('SELECT * FROM route_graph');
    const wKey=opt==='time'?'duration_mins':opt==='distance'?'distance_km':'base_price';

    const cityCoords={};
    rows.forEach(r=>{
      if(!cityCoords[r.city_from])cityCoords[r.city_from]={lat:parseFloat(r.from_lat),lng:parseFloat(r.from_lng)};
      if(!cityCoords[r.city_to])cityCoords[r.city_to]={lat:parseFloat(r.to_lat),lng:parseFloat(r.to_lng)};
    });

    const buildG=(filterFn)=>{
      const g=new Graph();
      rows.filter(filterFn).forEach(r=>g.addEdge(r.city_from,r.city_to,r[wKey],
        {price:r.base_price,duration:r.duration_mins,transport:r.transport_type,distance:r.distance_km}));
      return g;
    };

    const allG=buildG(()=>true);
    const result=allG.dijkstra(from,to);

    const pathWithCoords=result.path.map(city=>({
      city,
      lat:cityCoords[city]?.lat||0,
      lng:cityCoords[city]?.lng||0
    }));

    res.json({
      source:from,target:to,optimizedFor:opt,
      overall:{...result,pathWithCoords},
      byTransport:{
        flight:buildG(r=>r.transport_type==='flight').dijkstra(from,to),
        train:buildG(r=>r.transport_type==='train').dijkstra(from,to),
        bus:buildG(r=>r.transport_type==='bus').dijkstra(from,to),
      },
      cityCoords,
      cities:[...new Set(rows.map(r=>r.city_from))].sort()
    });
  }catch(e){console.error(e);res.status(500).json({error:'Server error'});}
});
