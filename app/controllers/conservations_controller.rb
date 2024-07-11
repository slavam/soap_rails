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
    code_base = {
      "rec_flag" => 1,
      proc: 21,
      period: 1,
    }
    code_360101 = code_base.merge({code: 360101, pkind: 10})
    
    water_level ={
      "rec_flag" => 3,
      code: 13205,
      units: 'm',
      proc: 0,
      period: 0,
    }
    water_level_deviation={
      "rec_flag" => 3,
      code: 13205,
      units: 'm',
      proc: 4,
      period: 86400,
      pkind: 4,
    }
    code_360103=code_base.merge(code: 360103)
    
    water_temperature={
      "rec_flag" => 3,
      code: 13082,
      units: 'k',
      proc: 0,
      period: 0,
    }
    code_360041=code_base.merge(code: 360041)
    
    air_temperature={
      # id: local_id,
      "rec_flag" => 3,
      code: 12101,
      units: 'k',
      # value: (params['airTemperature'].to_f + absolute_zero).round(2),
      height: 2,
      proc: 0,
      period: 0,
      # block: packet_id
    }
    code_360110=code_base.merge(code: 360110)
    
    ice_thickness = {
      "rec_flag" => 3,
      code: 13115,
      units: 'm',
      proc: 0,
      period: 0,
    }
    snow_thickness={
      "rec_flag" => 3,
      code: 13013,
      units: 'm',
      proc: 0,
      period: 0,
    }
    code_360065=code_base.merge(code: 360065)
    precipitation = {
      "rec_flag" => 3,
      code: 13011,
      units: "kg m-2",
      proc: 5,
      period: 86400,
      pkind: 4,
      height: 2,
    }
    duration_precipitation = {
      "rec_flag" => 4,
      code: 26020,
      units: "min",
      proc: 5,
      period: 86400,
      pkind: 4,
      height: 2,
    }

    item = []
    local_id = 0
    packet_id = 0
    if params['waterLevel'].present?
      local_id += 1
      packet_id = local_id
      code_360101[:id] = local_id
      item << code_360101
      local_id += 1
      water_level[:id] = local_id
      water_level[:value] = params['waterLevel'].to_f/100
      water_level[:block] = packet_id
      item << water_level
      local_id += 1
      water_level_deviation[:id] = local_id
      water_level_deviation[:value] = params['waterLevelDeviation'].to_f/100
      water_level_deviation[:block] = packet_id
      item << water_level_deviation
    end
    if params['waterTemperature'].present?
      local_id += 1
      packet_id = local_id
      code_360103[:id]=local_id
      item << code_360103
      local_id += 1
      water_temperature[:id] = local_id
      water_temperature[:value] = (params['waterTemperature'].to_f + absolute_zero).round(2)
      water_temperature[:block] = packet_id
      item << water_temperature
    end
    if params['airTemperature'].present?
      local_id += 1
      packet_id = local_id
      code_360041[:id] = local_id
      item << code_360041
      local_id += 1
      air_temperature[:id] = local_id
      air_temperature[:value] = (params['airTemperature'].to_f + absolute_zero).round(2)
      air_temperature[:block] = packet_id
      item << air_temperature
    end
    if params['iceThickness'].present?
      local_id+=1
      packet_id=local_id
      code_360110[:id] =local_id
      item<< code_360110
      local_id += 1
      ice_thickness[:id] = local_id
      ice_thickness[:value] = (params['iceThickness'].to_f/100).round(2)
      ice_thickness[block] = packet_id
      item << ice_thickness
    end
    if params['snowThickness'].present?
      local_id+=1
      packet_id=local_id
      code_360110[:id] =local_id
      item<< code_360110
      local_id += 1
      snow_thickness[:id] = local_id
      snow_thickness[:value] = (params['snowThickness'].to_f/100).round(2)
      snow_thickness[:block] = packet_id
      item << snow_thickness
    end
    if params["precipitation"].present?
      if(params["precipitation"].to_i<990)
        val = params["precipitation"]
      elsif (params["precipitation"].to_i==990)
        val = "-0.1"
      else
        val = ((params["precipitation"].to_i-990).to_f/10).round(1)
      end
      local_id+=1
      packet_id=local_id
      code_360065[:id] = local_id
      item << code_360065
      local_id += 1
      precipitation[:id] = local_id
      precipitation[:value] = val
      precipitation[:block] = packet_id
      item << precipitation
        
      interval = ['0','60','180','360','720']
      local_id += 1
      duration_precipitation[:id] = local_id
      duration_precipitation[:value] = interval[params["durationPrecipitation"].to_i]
      duration_precipitation[:block] = packet_id
      item << duration_precipitation
    end
    if params["ip0"].present?
      local_id+=1
      packet_id=local_id
      code_360110[:id] =local_id
      item<<code_360110
      ip_keys = params.keys.grep(/ip/)
      ip_keys.each{|k| 
        local_id += 1
        item << groups15_16(packet_id,local_id,params[k],13200)
      }
      ii_keys = params.keys.grep(/ii/)
      ii_keys.each{|k| 
        local_id += 1
        item << groups15_16_intens(packet_id,local_id,params[k],13202)
      }
    end
    if params["wb0"].present?
      local_id+=1
      packet_id=local_id
      code_360110[:id] =local_id
      item<<code_360110
      wb_keys = params.keys.grep(/wb/)
      wb_keys.each{|k| 
        local_id += 1
        item << groups15_16(packet_id,local_id,params[k],13201)
      }
      wi_keys = params.keys.grep(/wi/)
      wi_keys.each{|k| 
        local_id += 1
        item << groups15_16_intens(packet_id,local_id,params[k],13203)
      }
    end

    Rails.logger.debug("My object+++++++++++++++++: #{params.inspect}")
    client = Savon.client(wsdl: 'http://10.54.1.30:8650/wsdl', env_namespace: 'SOAP-ENV')
    message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], "meas_time_utc" => Time.now.strftime("%Y-%m-%d")+'T05:00', "syn_hour_utc"=>'05:00'},
      'DataList':{item: item}}
    response = client.call(:set_data, message: message)
    if params["wcDate"].present?
      item = []
      local_id = 1
      packet_id = local_id
      item << {
        id: local_id,
        "rec_flag" => 1,
        code: 360109,
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 4,
        code: 4194,
        units: 'ccitt ia5',
        value: params["wcDate"]+' '+params["wcHour"].rjust(2, '0')+':00:00',
        block: packet_id
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 4,
        code: 4002,
        units: 'mon',
        value: params["wcDate"][5,2],
        block: packet_id
      }
      local_id += 1
      packet_id = local_id
      item << {
        id: local_id,
        "rec_flag" => 1,
        code: 360109,
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13205,
        units: 'm',
        value: (params["wcWaterLevel"].to_f/100).round(2),
        block: packet_id
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13193,
        units: 'm3/s',
        value: params["waterConsumption"],
        block: packet_id
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13207,
        units: 'm2',
        value: params["riverArea"],
        block: packet_id
      }
      local_id += 1
      item << {
        id: local_id,
        "rec_flag" => 3,
        code: 13208,
        units: 'm',
        value: (params["maxDepth"].to_f/100).round(2),
        block: packet_id
      }
      message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], "meas_time_utc" => params["wcDate"]+'T'+(params["wcHour"].to_i-3).to_s.rjust(2, '0')+':00:00', "syn_hour_utc"=>"#{params["wcHour"].to_i-3}:00"},
        'DataList':{item: item}}
      response_water_consumption = client.call(:set_data, message: message)
    end
      # section 2
# 
# ret["obsDate2"+j]=obsDate
#     ret['waterLevel2'+j]=wl
#     ret['wlDeviation2'+j]=wld
#     if(waterTemp)
#       ret['waterTemp2'+j]=waterTemp
#     if(airTemp)
#       ret['airTemperature2'+j]=airTemp
#     if(ipChar2[0]!==null)
#       for (let i = 0; i < 5; i++) {
#         if(ipChar2[i]!==null){
#           ret = {...ret,[`ip${i*2}`]:ipChar2[i]}
#           if(ipAddon2[i]>10){ // character
#             if(ipAddon2[i]!==ipChar2[i])
#               ret = {...ret,[`ip${i*2+1}`]:ipAddon2[i]}
#           }else //intense
#             ret = {...ret,[`ii${i*2+1}`]:ipAddon2[i]}
#         }
#       }
#     if(wbChar2[0]!==null)
#       for (let i = 0; i < 5; i++) {
#         if(wbChar2[i]!==null){
#           ret = {...ret,[`wb${i*2}`]:wbChar2[i]}
#           if(wbAddon2[i]>10){
#             if(wbAddon2[i]!==wbChar2[i])
#               ret = {...ret,[`wb${i*2+1}`]:wbAddon2[i]}
#           }else
#             ret = {...ret,[`wi${i*2+1}`]:wbAddon2[i]}
#         }
#       }
#     if(iceThickness!==null)
#       hydroData["iThickness2"+j]=iceThickness
#     if(snowThickness!==null)
#       hydroData["sThickness2"+j]=snowThickness
#     if(precipitation!==null)
#       hydroData["precipitation2"+j]=precipitation
#     if(pDuration!==null)
#       hydroData["pDuration2"+j]=pDuration
# 

    if params["obsDate21"].present?
      # section21 = params["section21"].tr('\\','')
      # Rails.logger.debug("My object>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: #{section21.inspect}")
      item = []
      local_id = 0
      if params['waterLevel21'].present?
        local_id += 1
        packet_id = local_id
        code_360101[:id] = local_id
        item << code_360101
        local_id += 1
        water_level[:id] = local_id
        water_level[:value] = params['waterLevel21'].to_f/100
        water_level[:block] = packet_id
        item << water_level
        local_id += 1
        water_level_deviation[:id] = local_id
        water_level_deviation[:value] = params['wlDeviation21'].to_f/100
        water_level_deviation[:block] = packet_id
        item << water_level_deviation
      end
      if params['waterTemp21'].present?
        local_id += 1
        packet_id = local_id
        code_360103[:id]=local_id
        item << code_360103
        local_id += 1
        water_temperature[:id] = local_id
        water_temperature[:value] = (params['waterTemp21'].to_f + absolute_zero).round(2)
        water_temperature[:block] = packet_id
        item << water_temperature
      end
      if params['airTemperature21'].present?
        local_id += 1
        packet_id = local_id
        code_360041[:id] = local_id
        item << code_360041
        local_id += 1
        air_temperature[:id] = local_id
        air_temperature[:value] = (params['airTemperature21'].to_f + absolute_zero).round(2)
        air_temperature[:block] = packet_id
        item << air_temperature
      end
      if params['iThickness21'].present?
        local_id+=1
        packet_id=local_id
        code_360110[:id] =local_id
        item<< code_360110
        local_id += 1
        ice_thickness[:id] = local_id
        ice_thickness[:value] = (params['iThickness21'].to_f/100).round(2)
        ice_thickness[block] = packet_id
        item << ice_thickness
      end
      if params['sThickness21'].present?
        local_id+=1
        packet_id=local_id
        code_360110[:id] =local_id
        item<< code_360110
        local_id += 1
        snow_thickness[:id] = local_id
        snow_thickness[:value] = (params['sThickness21'].to_f/100).round(2)
        snow_thickness[:block] = packet_id
        item << snow_thickness
      end
      if params["precipitation21"].present?
        if(params["precipitation21"].to_i<990)
          val = params["precipitation21"]
        elsif (params["precipitation21"].to_i==990)
          val = "-0.1"
        else
          val = ((params["precipitation21"].to_i-990).to_f/10).round(1)
        end
        local_id+=1
        packet_id=local_id
        code_360065[:id] = local_id
        item << code_360065
        local_id += 1
        precipitation[:id] = local_id
        precipitation[:value] = val
        precipitation[:block] = packet_id
        item << precipitation
          
        interval = ['0','60','180','360','720']
        local_id += 1
        duration_precipitation[:id] = local_id
        duration_precipitation[:value] = interval[params["pDuration21"].to_i]
        duration_precipitation[:block] = packet_id
        item << duration_precipitation
      end
      if params["ip0"].present?
        local_id+=1
        packet_id=local_id
        code_360110[:id] =local_id
        item<<code_360110
        ip_keys = params.keys.grep(/ip/)
        ip_keys.each{|k| 
          local_id += 1
          item << groups15_16(packet_id,local_id,params[k],13200)
        }
        ii_keys = params.keys.grep(/ii/)
        ii_keys.each{|k| 
          local_id += 1
          item << groups15_16_intens(packet_id,local_id,params[k],13202)
        }
      end
      if params["wb0"].present?
        local_id+=1
        packet_id=local_id
        code_360110[:id] =local_id
        item<<code_360110
        wb_keys = params.keys.grep(/wb/)
        wb_keys.each{|k| 
          local_id += 1
          item << groups15_16(packet_id,local_id,params[k],13201)
        }
        wi_keys = params.keys.grep(/wi/)
        wi_keys.each{|k| 
          local_id += 1
          item << groups15_16_intens(packet_id,local_id,params[k],13203)
        }
      end
      # Rails.logger.debug("My object>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: #{params['obsDate21']+'T05:00'}")
      message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], "meas_time_utc" => params['obsDate21']+'T05:00', "syn_hour_utc"=>'05:00'},
        'DataList':{item: item}}
      response_section21 = client.call(:set_data, message: message)
    end
    
    if (response.success?)  # || (response_water_consumption.present? && response_water_consumption.success)
      save_stats = {response: response.body[:set_data_response], 
        response_water_consumption: response_water_consumption.present? ? response_water_consumption.body[:set_data_response]:nil,
        response_section21: response_section21.present? ? response_section21.body[:set_data_response]:nil
      }
      if params['telegram'].present?
        save_stats[:message] = save_telegram(params['telegram'])
      end
      Rails.logger.debug("My object+++++++++++++++++: #{save_stats.inspect}")
      render json: {response: save_stats}
    end
  end
  
    # HHZZ 83048 19082 10130 20000 96606 10130 20480 31154 40034 51810=
    def save_telegram telegram
      posts = [nil,83028,83035,83056,83060,83068,83074,83083,83478,83040,83036,83045,83050,83048,83026,78301,78413,78421,78427,78430,78434,78436]
      # uri = URI('http://localhost:3002/hydro_observations/create_hydro_telegram')
      # uri = URI('http://31.133.32.14:8080/hydro_observations/create_hydro_telegram')
      uri = URI('http://10.54.1.6:8080/hydro_observations/create_hydro_telegram')
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      param = {hydro_observation:
        {
          hydro_type: telegram[0,4], #'HHZZ',
          hydro_post_id: posts.index(telegram[5,5].to_i),
          hour_obs: telegram[13,2],
          date_observation: Time.now.strftime('%Y-%m-%d'),
          content_factor: telegram[15],
          telegram: telegram[5..]
        },
        date: Time.now.strftime('%Y-%m-%d'),
        input_mode: "normal"
      }.to_json
      req.body = param
      res = http.request(req)
      # Rails.logger.debug("My object+++++++++++++++++: #{res.body}")
      return JSON.parse(res.body)["errors"][0]
      # return "Done"
    end
  private
    def groups15_16(packet_id,id,value,code)
      ret = {
        id: id,
        "rec_flag" => 3,
        code: code,
        units: "code table",
        value: value,
        proc: 0,
        period: 0,
        block: packet_id
      }
    end
    def groups15_16_intens(packet_id,id,value,code)
      ret = {
        id: id,
        "rec_flag" => 4,
        code: code,
        units: "%",
        value: value.to_i*10,
        proc: 0,
        period: 0,
        block: packet_id
      } 
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
