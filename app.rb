# app.rb
require 'sinatra'
require 'json'
require 'net/http'
require 'uri'
require 'logger'

# Configure Sinatra
set :port, 4567
set :bind, '0.0.0.0'
set :public_folder, 'public'
set :views, 'views'

# Logger
logger = Logger.new(STDOUT)
logger.level = Logger::INFO

# MailerLite Configuration
MAILERLITE_API_KEY = ENV['MAILERLITE_API_KEY'] || 'your_mailerlite_api_key_here'
MAILERLITE_GROUP_ID = ENV['MAILERLITE_GROUP_ID'] || 'your_group_id_here'
MAILERLITE_API_URL = 'https://connect.mailerlite.com/api'

# Helper methods
helpers do
  def add_subscriber_to_mailerlite(email, name, phone)
    uri = URI("#{MAILERLITE_API_URL}/subscribers")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{MAILERLITE_API_KEY}"
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'

    # Prepare subscriber data
    subscriber_data = {
      email: email,
      fields: {
        name: name,
        phone: phone,
        source: 'Apexx Landing Page',
        signup_date: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        discount_code: 'EARLYBIRD30'
      },
      groups: [MAILERLITE_GROUP_ID],
      status: 'active'
    }

    request.body = JSON.generate(subscriber_data)

    begin
      response = http.request(request)
      logger.info "MailerLite API Response: #{response.code} - #{response.body}"

      case response.code.to_i
      when 200, 201
        JSON.parse(response.body)
      when 422
        # User already exists or validation error
        error_data = JSON.parse(response.body)
        logger.warn "MailerLite validation error: #{error_data}"
        { 'error' => 'subscriber_exists_or_invalid' }
      else
        logger.error "MailerLite API error: #{response.code} - #{response.body}"
        { 'error' => 'api_error' }
      end
    rescue => e
      logger.error "MailerLite request failed: #{e.message}"
      { 'error' => 'request_failed' }
    end
  end

  def send_welcome_email(email, name)
    # Optional: Send a custom welcome email via MailerLite automation
    # This would trigger a welcome sequence you've set up in MailerLite
    uri = URI("#{MAILERLITE_API_URL}/automations/trigger")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{MAILERLITE_API_KEY}"
    request['Content-Type'] = 'application/json'

    trigger_data = {
      email: email,
      automation_id: ENV['WELCOME_AUTOMATION_ID'], # Set this in your environment
      data: {
        name: name,
        discount_code: 'EARLYBIRD30',
        discount_amount: '30%'
      }
    }

    request.body = JSON.generate(trigger_data)

    begin
      response = http.request(request)
      logger.info "Welcome email trigger response: #{response.code}"
      response.code.to_i == 200
    rescue => e
      logger.error "Welcome email trigger failed: #{e.message}"
      false
    end
  end

  def validate_email(email)
    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def validate_phone(phone)
    # Basic phone validation - adjust regex based on your requirements
    phone.gsub(/\D/, '').length >= 10
  end
end

# Routes
get '/' do
  # Serve the landing page HTML
  content_type 'text/html'
  File.read(File.join('public', 'index.html'))
end

post '/subscribe' do
  content_type :json

  # Extract form data
  email = params[:email]&.strip&.downcase
  name = params[:name]&.strip
  phone = params[:phone]&.strip

  # Validation
  errors = []
  errors << 'Email is required' if email.nil? || email.empty?
  errors << 'Invalid email format' if email && !validate_email(email)
  errors << 'Name is required' if name.nil? || name.empty?
  errors << 'Phone is required' if phone.nil? || phone.empty?
  errors << 'Invalid phone format' if phone && !validate_phone(phone)

  if errors.any?
    status 400
    return { error: 'validation_failed', messages: errors }.to_json
  end

  # Add subscriber to MailerLite
  logger.info "Adding subscriber: #{email} (#{name})"
  result = add_subscriber_to_mailerlite(email, name, phone)

  if result['error']
    case result['error']
    when 'subscriber_exists_or_invalid'
      # Still consider this a success for UX purposes
      logger.info "Subscriber already exists: #{email}"
      status 200
      return {
        success: true,
        message: 'Welcome back! Your early-bird discount is confirmed.',
        already_subscribed: true
      }.to_json
    else
      logger.error "Failed to add subscriber: #{result['error']}"
      status 500
      return { error: 'subscription_failed', message: 'Please try again later.' }.to_json
    end
  end

  # Send welcome email (optional)
  if ENV['WELCOME_AUTOMATION_ID']
    send_welcome_email(email, name)
  end

  # Log successful subscription
  logger.info "Successfully subscribed: #{email}"

  # Return success response
  status 200
  {
    success: true,
    message: 'Successfully reserved your early-bird discount!',
    subscriber_id: result['data']&.dig('id'),
    discount_code: 'EARLYBIRD30'
  }.to_json
end

# Health check endpoint
get '/health' do
  content_type :json
  { status: 'ok', timestamp: Time.now.iso8601 }.to_json
end

# Admin endpoint to check subscriber count (optional)
get '/admin/stats' do
  # Simple authentication - use proper auth in production
  halt 401 unless params[:token] == ENV['ADMIN_TOKEN']

  content_type :json
  # You could add logic here to fetch actual subscriber count from MailerLite
  {
    total_subscribers: 13, # This would be fetched from MailerLite API
    spots_remaining: 87,
    last_updated: Time.now.iso8601
  }.to_json
end

# Error handlers
error 404 do
  if request.accept.include?('application/json')
    content_type :json
    { error: 'not_found', message: 'Endpoint not found' }.to_json
  else
    redirect '/'
  end
end

error 500 do
  logger.error "Server error: #{env['sinatra.error']}"

  if request.accept.include?('application/json')
    content_type :json
    { error: 'server_error', message: 'Internal server error' }.to_json
  else
    'Something went wrong. Please try again later.'
  end
end

# Start the server
if __FILE__ == $0
  logger.info "Starting Apexx Landing Page server on port #{settings.port}"
  logger.info "MailerLite integration: #{MAILERLITE_API_KEY ? 'Enabled' : 'Disabled (set MAILERLITE_API_KEY)'}"
end
