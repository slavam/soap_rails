class StationsController < ApplicationController
  before_action :cors_preflight_check
  # skip_before_action :verify_authenticity_token, :only => [:create_synoptic_telegram]
  def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
  def meteostations
    stations = Station.new
    @meteostations = stations.meteostations
    # StationMailer.test_email.deliver_now
    respond_to do |format|
      format.html
      format.json do
        render json: {meteostations: @meteostations}
      end
    end
  end
  def hydroposts
    stations = Station.new
    render json: {hydroposts: stations.hydroposts}
  end
end