class ObservationsController < ApplicationController
  def observations
    params.to_enum.to_h
# Rails.logger.debug(">>>>>>>>>>>#{observation_params}<<<<<<<<<")
#    p = params.present? ? params : {}
    o = Observation.new(observation_params)
    render json: o.observations.present? ? o.observations : []
  end

  private
    def observation_params
      params.permit(:stations, :sources, :limit, :before, :after, :hashes, :syn_hours)
    end
end