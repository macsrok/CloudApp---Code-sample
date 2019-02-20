Rails.application.routes.draw do
  post '/API/scrape_assets', to: 'api#assets_from_url'
end
