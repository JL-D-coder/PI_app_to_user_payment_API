# Pi Payment API (Sinatra + Supabase)

This is a **Sinatra-based API** that integrates **Pi Network payments** and stores transaction details in a **Supabase PostgreSQL database**.

---

## **🚀 Features**
- Create and submit Pi Network payments.
- Store transaction details (payment ID, TXID) in Supabase.
- Secure environment variable setup.
- Easily deployable on a Linux VPS.

---

## **🛠 Installation**

### **1️⃣ Clone the Repository**
```sh
git clone https://github.com/your-username/pi-payment-api.git
cd pi-payment-api
```

### **2️⃣ Install Dependencies**
```sh
gem install bundler
bundle install
```

### **3️⃣ Set Up Environment Variables**
Create a `.env` file in the project root and add:
```env
SUPABASE_DB_URL=postgres://your_user:your_password@your_host:5432/your_database
SUPABASE_KEY=your_service_role_key
PI_API_KEY=your_pi_api_key
PI_WALLET_PRIVATE_KEY=your_wallet_private_key
```
🔹 Replace with your actual **Supabase** and **Pi Network** credentials.

---

## **📝 API Endpoints**

### **1️⃣ Create a Payment**
**Endpoint:** `POST /create_payment`
```json
{
  "uid": "user123",
  "amount": 3.14,
  "memo": "Refund",
  "metadata": { "product_id": "apple-pie-1" }
}
```
📌 **Response:**
```json
{
  "message": "Payment created successfully",
  "payment_id": "pi_123456789"
}
```

### **2️⃣ Submit a Payment to Pi Blockchain**
**Endpoint:** `POST /submit_payment`
```json
{
  "payment_id": "pi_123456789"
}
```
📌 **Response:**
```json
{
  "message": "Payment submitted",
  "txid": "tx_987654321"
}
```

### **3️⃣ Complete a Payment**
**Endpoint:** `POST /complete_payment`
```json
{
  "payment_id": "pi_123456789",
  "txid": "tx_987654321"
}
```
📌 **Response:**
```json
{
  "message": "Payment completed",
  "payment": { "status": "completed" }
}
```

---

## **💾 Database Schema (Supabase)**
Run this SQL in **Supabase SQL Editor**:
```sql
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    uid TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    memo TEXT,
    payment_id TEXT UNIQUE,
    txid TEXT UNIQUE,
    status TEXT DEFAULT 'pending'
);
```

---

## **🚀 Running the API**
### **1️⃣ Start the Server**
```sh
rackup
```
📌 The API runs on `http://localhost:4567/`

### **2️⃣ Test Using cURL**
```sh
curl -X POST http://localhost:4567/create_payment \
     -H "Content-Type: application/json" \
     -d '{"uid": "user123", "amount": 3.14, "memo": "Refund", "metadata": {"product_id": "apple-pie-1"}}'
```

---

## **🌍 Deployment (Linux VPS)**
### **1️⃣ Install Required Packages on VPS**
```sh
sudo apt update
sudo apt install ruby-full libpq-dev build-essential
```
### **2️⃣ Clone the Project and Install Dependencies**
```sh
git clone https://github.com/your-username/pi-payment-api.git
cd pi-payment-api
bundle install
```
### **3️⃣ Start API on VPS**
```sh
rackup -o 0.0.0.0
```

---

## **🔒 Security Best Practices**
✅ **NEVER** expose `SUPABASE_KEY` or `PI_WALLET_PRIVATE_KEY` in frontend code.
✅ Use **environment variables** instead of hardcoding keys.
✅ Consider using **JWT authentication** for API security.

---

## **📌 Next Steps**
- ✅ Implement **authentication** using JWT tokens.
- ✅ Add **real-time payment status updates**.
- ✅ Set up **automated deployment** with Docker or Systemd.

---

## **💬 Need Help?**
If you run into issues, feel free to ask! 🚀

