require 'sinatra'
require 'json'
require 'pg'
require 'dotenv/load'
require 'pinetwork'
require 'multipart/post'
include Multipart::Post

class String
    def starts_with?(prefix)
      start_with?(prefix) # Redirects to the correct method
    end
  end
  

# Ensure environment variables are set
PI_API_KEY = ENV.fetch('PI_API_KEY') { raise 'PI_API_KEY is missing from environment variables' }
PI_WALLET_PRIVATE_SEED = ENV.fetch('PI_WALLET_PRIVATE_SEED') { raise 'PI_WALLET_PRIVATE_KEY is missing from environment variables' }

# Initialize Supabase DB connection
DB = PG.connect(ENV.fetch('SUPABASE_DB_URL') { raise 'SUPABASE_DB_URL is missing from environment variables' })

# Initialize Pi Network SDK
pi = PiNetwork.new(api_key: PI_API_KEY, wallet_private_key: PI_WALLET_PRIVATE_SEED)

# Route to create a new Pi payment
post '/create_payment' do
  content_type :json
  data = JSON.parse(request.body.read)

  user_uid = data["uid"]
  amount = data["amount"]
  memo = data["memo"]
  metadata = data["metadata"]

  # Create payment using Pi SDK
  payment_data = {
    amount: amount,
    memo: memo,
    metadata: metadata,
    uid: user_uid
  }

  payment_id = pi.create_payment(payment_data)

  # Store payment details in Supabase
  DB.exec_params("INSERT INTO payments (uid, amount, memo, payment_id) VALUES ($1, $2, $3, $4)",
                 [user_uid, amount, memo, payment_id])

  { message: "Payment created successfully", payment_id: payment_id }.to_json
end

# Route to submit a Pi payment
post '/submit_payment' do
    content_type :json
    data = JSON.parse(request.body.read)
    
    payment_id = data["payment_id"]
  
    if payment_id.nil? || payment_id.strip.empty?
      status 400
      return { error: "Missing or invalid payment_id" }.to_json
    end
  
    begin
      puts "Submitting payment for ID: #{payment_id}"  # Debugging log
      txid = pi.submit_payment(payment_id)
  
      DB.exec_params("UPDATE payments SET txid = $1 WHERE payment_id = $2", [txid, payment_id])
  
      { message: "Payment submitted", txid: txid }.to_json
    rescue StandardError => e
      puts "Error in submit_payment: #{e.message}"
      status 500
      { error: "Failed to submit payment", details: e.message }.to_json
    end
end
  

# Route to complete a Pi payment
post '/complete_payment' do
  content_type :json
  data = JSON.parse(request.body.read)

  payment_id = data["payment_id"]
  txid = data["txid"]

  # Complete the payment
  payment = pi.complete_payment(payment_id, txid)

  # Mark as completed in database
  DB.exec_params("UPDATE payments SET status = 'completed' WHERE payment_id = $1",
                 [payment_id])

  { message: "Payment completed", payment: payment }.to_json
end
