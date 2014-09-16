STDOUT.sync = STDERR.sync = true

require_relative 'config/environment'

require "toshi/web/www"
require "toshi/web/api"
require "toshi/web/websocket"
require 'sidekiq/web'

use Rack::CommonLogger
use Bugsnag::Rack

app = Rack::URLMap.new(
  '/'          => Toshi::Web::WWW,
  '/api/v0'    => Toshi::Web::Api,
)

map '/sidekiq' do
  if Toshi.env == :production
    if Toshi.settings[:sidekiq_username] && Toshi.settings[:sidekiq_password]
      use Rack::Auth::Basic, "Protected Area" do |username, password|
        username == Toshi.settings[:sidekiq_username] && password == Toshi.settings[:sidekiq_password]
      end
      run Sidekiq::Web
    end
  else
    run Sidekiq::Web
  end
end

app = Toshi::Web::WebSockets.new(app)

run app
