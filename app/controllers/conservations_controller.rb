class ConservationsController < ApplicationController
  before_action :cors_preflight_check
  def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
  def save_hydro_data
    absolute_zero = 273.15
    item = []
    local_id = 0
    packet_id = 0
    if params['waterLevel'].present?
      local_id += 1
      packet_id = local_id
      item << {
        id: local_id,
        "rec_flag" => 1,
        code: 360101,
        proc: 21,
        period: 1,
        pkind: 10
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13205,
        units: 'm',
        value: params['waterLevel'].to_f/100,
        proc: 0,
        period: 0,
        block: packet_id
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13205,
        units: 'm',
        value: params['waterLevelDeviation'].to_f/100,
        proc: 4,
        period: 86400,
        pkind: 4,
        block: packet_id
      }
    end
    if params['waterTemperature'].present?
      local_id += 1
      packet_id = local_id
      item << {
        id: local_id,
        "rec_flag" => 1,
        code: 360103,
        proc: 21,
        period: 1,
        # pkind: 10
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13082,
        units: 'k',
        value: (params['waterTemperature'].to_f + absolute_zero).round(2),
        proc: 0,
        period: 0,
        block: packet_id
      }
    end
    if params['airTemperature'].present?
      local_id += 1
      packet_id = local_id
      item << {
        id: local_id,
        "rec_flag" => 1,
        code: 360041,
        proc: 21,
        period: 1,
        # pkind: 10
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 12101,
        units: 'k',
        value: (params['airTemperature'].to_f + absolute_zero).round(2),
        height: 2,
        proc: 0,
        period: 0,
        block: packet_id
      }
    end
    if params['iceThickness'].present?
      local_id+=1
      packet_id=local_id
      item<<{
        id: local_id,
        "rec_flag" => 1,
        code: 360110,
        proc: 21,
        period: 1,
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13115,
        units: 'm',
        value: (params['iceThickness'].to_f/100).round(2),
        proc: 0,
        period: 0,
        block: packet_id
      }
    end
    if params['snowThickness'].present?
      local_id+=1
      packet_id=local_id
      item<<{
        id: local_id,
        "rec_flag" => 1,
        code: 360110, # 360083
        proc: 21,
        period: 1,
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13013,
        units: 'm',
        value: (params['snowThickness'].to_f/100).round(2),
        proc: 0,
        period: 0,
        block: packet_id
      }
    end
    if params["precipitation"].present?
      if params["precipitation"]=='000'
        val = "-0.1"
      elsif (params["precipitation"].to_i>=990) && (params["precipitation"].to_i<=999)
        val = ((params["precipitation"].to_i-990).to_f/10).round(1)
      else
        val = params["precipitation"]
      end
      local_id+=1
      packet_id=local_id
      item<<{
        id: local_id,
        "rec_flag" => 1,
        code: 360065, 
        proc: 21,
        period: 1,
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13011,
        units: "kg m-2",
        value: val,
        proc: 5,
        period: 86400,
        pkind: 4,
        height: 2,
        block: packet_id
      }
      interval = ['0','60','180','360','720']
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 4,
        code: 26020,
        units: "min",
        value: interval[params["durationPrecipitation"].to_i],
        proc: 5,
        period: 86400,
        pkind: 4,
        height: 2,
        block: packet_id
      }
    end
    Rails.logger.debug("My object+++++++++++++++++: #{params.inspect}")
    client = Savon.client(wsdl: 'http://10.54.1.30:8650/wsdl', env_namespace: 'SOAP-ENV')
    message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], "meas_time_utc" => Time.now.strftime("%Y-%m-%d")+'T05:00', "syn_hour_utc"=>'05:00'},
      'DataList':{item: item}}
    response = client.call(:set_data, message: message)
    if response.success?
      save_stats = response.body[:set_data_response]
      Rails.logger.debug("My object+++++++++++++++++: #{save_stats.inspect}")
      render json: {response: save_stats}
    end
  end
end

# hydroData = {
#     //   'Report': {
#     //     station: hydroPostCode,
#     //     meas_time_utc: `${currDate.toISOString().split('T')[0]}T${term}:00:00`
#     //   },
#     //   data_list: {
#     //     item: [
#     //       {
#     //         id: 1,
#     //         rec_flag: 1,
#     //         code: 360101,
#     //         proc: 21,
#     //         period: 1,
#     //         pkind: 10
#     //       },
#     //       { // water level
#     //         id: 2,
#     //         rec_flag: 3,
#     //         code: 13205,
#     //         unit: 'm',
#     //         value: waterLevel/100,
#     //         block:1
#     //       }
# SetDataResponse xmlns:NS1="urn:CSDNIntf-ICSDN">
#    <SuccessCount>23</SuccessCount>
#    <FailedCount>0</FailedCount>
#    <DetailMessage
#     if(snowThickness!==null)
#       hydroData["snowThickness"]=snowThickness
#     if(precipitation!==null)
#       hydroData["precipitation"]=precipitation
#     if(durationPrecipitation!==null)
#       hydroData["durationPrecipitation
