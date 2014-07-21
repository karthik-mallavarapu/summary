require 'resque/server'
require 'resque-scheduler'

Resque.redis = Redis.new(host: 'localhost', port: 6379, password: 'rFTFcHHK')
Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")