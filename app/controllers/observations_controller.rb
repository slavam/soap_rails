class ObservationsController < ApplicationController
  before_action :cors_preflight_check
  # skip_before_action :verify_authenticity_token, :only => [:create_synoptic_telegram]
  def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
  def observations
    params.to_enum.to_h
  Rails.logger.debug(">>>>>>>>>>>#{observation_params}<<<<<<<<<")
#    p = params.present? ? params : {}
    o = Observation.new(observation_params)
    render json: o.observations.present? ? o.observations : []
  end

  private
    def observation_params
      params.permit(:stations, :sources, :streams, :limit, :before, :after, :hashes, :syn_hours, :min_quality)
    end
end
