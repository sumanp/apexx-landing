# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'logger'

# Configure Sinatra
set :port, 4567
set :bind, '0.0.0.0'
set :public_folder, 'public'
set :views, 'views'

# Logger
logger = Logger.new($stdout)
logger.level = Logger::INFO


# Routes
get '/' do
  # Serve the landing page HTML
  send_file File.join(settings.public_folder, 'index.html')
end

# Health check endpoint
get '/health' do
  content_type :json
  { status: 'ok', timestamp: Time.now.iso8601 }.to_json
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
end
