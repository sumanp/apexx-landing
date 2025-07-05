FROM ruby:3.0.7

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential curl

# Set up app dir
WORKDIR /app

# Copy Gemfiles & install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the app
COPY . .

# Expose port
EXPOSE 4567

# Start app with Puma
CMD ["bundle", "exec", "puma", "-C", "puma.rb"]
