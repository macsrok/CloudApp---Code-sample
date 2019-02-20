class ApiController < ActionController::Base
  def assets_from_url
    assets = AssetScrapeService.new({url:params[:url]}).call!
    if assets
      render json: assets.to_json
    else
      render json: {ERROR: 'FAILED TO PARSE PAGE'}.to_json, status: :unprocessable_entity
    end
  end
end