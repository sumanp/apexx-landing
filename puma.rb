# frozen_string_literal: true

port ENV.fetch('PORT', 4567)
environment ENV.fetch('RACK_ENV', 'production')
workers ENV.fetch('WEB_CONCURRENCY', 2).to_i
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
threads threads_count, threads_count

preload_app!

on_worker_boot do
  puts 'Worker booted!'
end

on_worker_shutdown do
  puts 'Worker shutting down...'
end

plugin :tmp_restart
