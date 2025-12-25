class ConservationsController < ApplicationController
  before_action :cors_preflight_check
  def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
  def water_level_and_deviation_items(wl_value, wld_value)
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
    @local_id += 1
    packet_id = @local_id
    @item << Conservation::CBASE.merge({code: 360101, pkind: 10, id: @local_id})
    @local_id += 1
    @item << water_level.merge(id: @local_id, value: wl_value, block: packet_id)
    @local_id += 1
    @item << water_level_deviation.merge(id: @local_id, value: wld_value, block: packet_id)
  end
  def water_temperature_item(wt_value)
    water_temperature={
      "rec_flag" => 3,
      code: 13082,
      units: 'k',
      proc: 0,
      period: 0,
    }
    @local_id += 1
    packet_id = @local_id
    @item << Conservation::CBASE.merge(code: 360103,id: @local_id)
    @local_id += 1
    water_temperature[:id] = @local_id
    water_temperature[:value] = wt_value
    water_temperature[:block] = packet_id
    @item << water_temperature
  end
  def air_temperature_item(at_value)
    air_temperature={
      "rec_flag" => 3,
      code: 12101,
      units: 'k',
      height: 2,
      proc: 0,
      period: 0,
    }
    @local_id += 1
    packet_id = @local_id
    @item << Conservation::CBASE.merge(id: @local_id, code: 360041)
    @local_id += 1
    @item << air_temperature.merge(id: @local_id, value: at_value, block: packet_id)
  end
  def ice_thickness_item(it_value)
    ice_thickness = {
      "rec_flag" => 3,
      code: 13115,
      units: 'm',
      proc: 0,
      period: 0,
    }
    @local_id+=1
    packet_id=@local_id
    @item<< Conservation::CBASE.merge(id: @local_id, code: 360110)
    @local_id += 1
    @item << ice_thickness.merge(id: @local_id, value: it_value, block: packet_id)
  end
  def snow_thickness_item(st_value)
    snow_thickness={
      "rec_flag" => 3,
      code: 13013,
      units: 'm',
      proc: 0,
      period: 0,
    }
    @local_id+=1
    packet_id=@local_id
    @item<< Conservation::CBASE.merge(id: @local_id, code: 360110)
    @local_id += 1
    @item << snow_thickness.merge(id: @local_id, value: st_value, block: packet_id)
  end
  def precipitation_and_duration_items(p_value, pd_value)
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
    @local_id+=1
    packet_id=@local_id
    @item << Conservation::CBASE.merge(id: @local_id, code: 360065)
    @local_id += 1
    @item << precipitation.merge(id: @local_id, value: p_value, block: packet_id)
    @local_id += 1
    @item << duration_precipitation.merge(id: @local_id, value: pd_value, block: packet_id)
  end

  def save_hydro_data
    absolute_zero = 273.15
    @interval = ['0','60','180','360','720']
    @item = []
    @local_id = 0
    packet_id = 0
    if params['waterLevel'].present?
      water_level_and_deviation_items(params['waterLevel'].to_f/100, params['waterLevelDeviation'].to_f/100)
    end
    if params['waterTemperature'].present?
      water_temperature_item((params['waterTemperature'].to_f + absolute_zero).round(2))
    end
    if params['airTemperature'].present?
      air_temperature_item((params['airTemperature'].to_f + absolute_zero).round(2))
    end
    if params['iceThickness'].present?
      ice_thickness_item((params['iceThickness'].to_f/100).round(2))
    end
    if params['snowThickness'].present?
      snow_thickness_item((params['snowThickness'].to_f/100).round(2))
    end
    if params["precipitation"].present?
      if(params["precipitation"].to_i<990)
        val = params["precipitation"]
      elsif (params["precipitation"].to_i==990)
        val = "-0.1"
      else
        val = ((params["precipitation"].to_i-990).to_f/10).round(1)
      end
      # interval = ['0','60','180','360','720']
      precipitation_and_duration_items(val,@interval[params["durationPrecipitation"].to_i])
      
    end
    if params["ip"].present?
      @local_id+=1
      packet_id=@local_id
      @item<< Conservation::CBASE.merge(id: @local_id, code: 360110)
      ipChar = params['ip'].split(',')
      ipAddon = params['ii'].split(',')
      ipChar.each_with_index do |val, i|  
        @local_id += 1
        ip_id=@local_id
        @item << groups15_16(packet_id,@local_id,val,13200)
        @local_id += 1
        if ipAddon[i].to_i>10
          @item << groups15_16(packet_id,@local_id,ipAddon[i],13200)
        else
          @item << groups15_16_intens(ip_id,@local_id,ipAddon[i],13202)
        end
      end
    end
    if params["wb0"].present?
      @local_id+=1
      packet_id=@local_id
      @item << Conservation::CBASE.merge(id: @local_id, code: 360111)
      wb_keys = params.keys.grep(/wb/)
      wb_keys.each{|k| 
        @local_id += 1
        @item << groups15_16(packet_id,@local_id,params[k],13201)
      }
      wi_keys = params.keys.grep(/wi/)
      wi_keys.each{|k| 
        @local_id += 1
        @item << groups15_16_intens(packet_id,@local_id,params[k],13203)
      }
    end

    # Rails.logger.debug("My object+++++++++++++++++: #{params.inspect}")
    client = Savon.client(wsdl: 'http://10.54.1.31:8650/wsdl', env_namespace: 'SOAP-ENV')
    client2 = Savon.client(wsdl: 'http://10.54.1.32:8650/wsdl', env_namespace: 'SOAP-ENV')
    message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], "meas_time_utc" => Time.now.strftime("%Y-%m-%d")+'T05:00', "syn_hour_utc"=>'05:00'},
      'DataList':{item: @item}}
    response = client.call(:set_data, message: message)
    response2 = client2.call(:set_data, message: message)
    if params["wcDate"].present?
      @item = []
      @local_id = 1
      packet_id = @local_id
      @item << {id: @local_id,"rec_flag" => 1,code: 360109}
      @local_id += 1
      @item << {
        id: @local_id,
        "rec_flag" => 4,
        code: 4002,
        units: 'mon',
        value: params["wcDate"][5,2].to_i,
        block: packet_id
      }
      @local_id += 1
      @item << {
        id: @local_id,
        "rec_flag" => 4,
        code: 4194,
        units: 'ccitt ia5',
        value: params["wcDate"]+' '+params["wcHour"].rjust(2, '0')+':00:00',
        block: packet_id
      }
      # @local_id += 1
      # packet_id = @local_id
      # @item << {id: @local_id,"rec_flag" => 1,code: 360109}
      @local_id += 1
      @item << {
        id: @local_id,
        "rec_flag" => 3,
        code: 13205,
        units: 'm',
        value: (params["wcWaterLevel"].to_f/100).round(2),
        block: packet_id
      }
      @local_id += 1
      @item << {
        id: @local_id,
        "rec_flag" => 3,
        code: 13193,
        units: 'm3/s',
        value: params["waterConsumption"],
        block: packet_id
      }
      @local_id += 1
      @item << {
        id: @local_id,
        "rec_flag" => 3,
        code: 13207,
        units: 'm2',
        value: params["riverArea"],
        block: packet_id
      }
      @local_id += 1
      @item << {
        id: @local_id,
        "rec_flag" => 3,
        code: 13208,
        units: 'm',
        value: (params["maxDepth"].to_f/100).round(2),
        block: packet_id
      }
      message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], "meas_time_utc" => params["wcDate"]+'T'+(params["wcHour"].to_i-3).to_s.rjust(2, '0')+':00:00', "syn_hour_utc"=>"#{params["wcHour"].to_i-3}:00"},
        'DataList':{item: @item}}
      response_water_consumption = client.call(:set_data, message: message)
      response2_water_consumption = client2.call(:set_data, message: message)
    end
      # section 2

    if params["obsDate21"].present?
      # section21 = params["section21"].tr('\\','')
      # Rails.logger.debug("My object>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: #{section21.inspect}")
      @item = []
      @local_id = 0
      if params['waterLevel21'].present?
        water_level_and_deviation_items(params['waterLevel21'].to_f/100,params['wlDeviation21'].to_f/100)
      end
      if params['waterTemp21'].present?
        water_temperature_item((params['waterTemp21'].to_f + absolute_zero).round(2))
      end
      if params['airTemperature21'].present?
        air_temperature_item((params['airTemperature21'].to_f + absolute_zero).round(2))
      end
      if params['iThickness21'].present?
        ice_thickness_item((params['iThickness21'].to_f/100).round(2))
      end
      if params['sThickness21'].present?
        snow_thickness_item((params['sThickness21'].to_f/100).round(2))
      end
      if params["precipitation21"].present?
        if(params["precipitation21"].to_i<990)
          val = params["precipitation21"]
        elsif (params["precipitation21"].to_i==990)
          val = "-0.1"
        else
          val = ((params["precipitation21"].to_i-990).to_f/10).round(1)
        end
        # interval = ['0','60','180','360','720']
        precipitation_and_duration_items(val, @interval[params["pDuration21"].to_i])
      end
      if params["ip0"].present?
        @local_id+=1
        packet_id=@local_id
        @item << Conservation::CBASE.merge(id: @local_id, code: 360110)
        ip_keys = params.keys.grep(/ip/)
        ip_keys.each{|k| 
          @local_id += 1
          @item << groups15_16(packet_id,@local_id,params[k],13200)
        }
        ii_keys = params.keys.grep(/ii/)
        ii_keys.each{|k| 
          @local_id += 1
          @item << groups15_16_intens(packet_id,@local_id,params[k],13202)
        }
      end
      if params["wb0"].present?
        @local_id+=1
        packet_id=@local_id
        @item << Conservation::CBASE.merge(id: @local_id, code: 360110)
        wb_keys = params.keys.grep(/wb/)
        wb_keys.each{|k| 
          @local_id += 1
          @item << groups15_16(packet_id,@local_id,params[k],13201)
        }
        wi_keys = params.keys.grep(/wi/)
        wi_keys.each{|k| 
          @local_id += 1
          @item << groups15_16_intens(packet_id,@local_id,params[k],13203)
        }
      end
      # Rails.logger.debug("My object>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: #{params['obsDate21']+'T05:00'}")
      message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], "meas_time_utc" => params['obsDate21']+'T05:00', "syn_hour_utc"=>'05:00'},
        'DataList':{item: @item}}
      response_section21 = client.call(:set_data, message: message)
      response2_section21 = client2.call(:set_data, message: message)
    end
    # section 22
    if params["obsDate22"].present?
      # section21 = params["section21"].tr('\\','')
      # Rails.logger.debug("My object>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: #{section21.inspect}")
      @item = []
      @local_id = 0
      if params['waterLevel22'].present?
        water_level_and_deviation_items(params['waterLevel22'].to_f/100,params['wlDeviation22'].to_f/100)
      end
      if params['waterTemp22'].present?
        water_temperature_item((params['waterTemp22'].to_f + absolute_zero).round(2))
      end
      if params['airTemperature22'].present?
        air_temperature_item((params['airTemperature22'].to_f + absolute_zero).round(2))
      end
      if params['iThickness22'].present?
        ice_thickness_item((params['iThickness22'].to_f/100).round(2))
      end
      if params['sThickness22'].present?
        snow_thickness_item((params['sThickness22'].to_f/100).round(2))
      end
      if params["precipitation22"].present?
        if(params["precipitation22"].to_i<990)
          val = params["precipitation22"]
        elsif (params["precipitation22"].to_i==990)
          val = "-0.1"
        else
          val = ((params["precipitation22"].to_i-990).to_f/10).round(1)
        end
        # interval = ['0','60','180','360','720']
        precipitation_and_duration_items(val, @interval[params["pDuration22"].to_i])
      end
      if params["ip0"].present?
        @local_id+=1
        packet_id=@local_id
        @item << Conservation::CBASE.merge(id: @local_id, code: 360110)
        ip_keys = params.keys.grep(/ip/)
        ip_keys.each{|k| 
          @local_id += 1
          @item << groups15_16(packet_id,@local_id,params[k],13200)
        }
        ii_keys = params.keys.grep(/ii/)
        ii_keys.each{|k| 
          @local_id += 1
          @item << groups15_16_intens(packet_id,@local_id,params[k],13202)
        }
      end
      if params["wb0"].present?
        @local_id+=1
        packet_id=@local_id
        @item << Conservation::CBASE.merge(id: @local_id, code: 360110)
        wb_keys = params.keys.grep(/wb/)
        wb_keys.each{|k| 
          @local_id += 1
          @item << groups15_16(packet_id,@local_id,params[k],13201)
        }
        wi_keys = params.keys.grep(/wi/)
        wi_keys.each{|k| 
          @local_id += 1
          @item << groups15_16_intens(packet_id,@local_id,params[k],13203)
        }
      end
      # Rails.logger.debug("My object>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: #{params['obsDate21']+'T05:00'}")
      message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], "meas_time_utc" => params['obsDate22']+'T05:00', "syn_hour_utc"=>'05:00'},
        'DataList':{item: @item}}
      response_section22 = client.call(:set_data, message: message)
      response2_section22 = client2.call(:set_data, message: message)
    end
    # section 3    
    if params["period0"].present?
      @item = []
      @local_id = 1
      packet_id = 1
      # @item << {id:@local_id, code: 360102}
      if params['avgWl0'].present?
        @local_id+=1
        packet_id=@local_id
        @item << Conservation::CBASE.merge(id: @local_id, code: 360101, proc:1, pkind: 98)
        @local_id += 1
        @item << {id: @local_id, proc: 1, period: params['period0'], 
          code:13205, value: params['avgWl0'].to_f/100, block: packet_id, "rec_flag" => 3, pkind: 98}
      end
      if params['minWl0'].present?
        @local_id+=1
        packet_id=@local_id
        @item << Conservation::CBASE.merge(id: @local_id, code: 360101)
        @local_id += 1
        @item << {id: @local_id, value: params['minWl0'].to_f/100, code: 13205, "rec_flag" => 3, proc: 3, period: params['period0'].to_i, pkind: 98, block: packet_id}
      end
      if params['maxWl0'].present?
        @local_id+=1
        packet_id=@local_id
        @item << {id: @local_id, code: 360101, "rec_flag"=>1, proc:2, period: params['period0'].to_i, pkind: 98}
        @local_id += 1
        @item << {id: @local_id, value: params['maxWl0'].to_f/100, code: 13205, "rec_flag"=> 3, proc: 2, period: params['period0'].to_i, pkind: 98, block: packet_id}
        if params['mlDate0'].present?
          packet_id=@local_id
          @local_id += 1
          @item << {
            id: @local_id, 
            value: "#{params['mlDate0']} #{params['mlHour0']}:00:00",
            code: 4194,
            units: "ccitt ia5",
            "rec_flag" => 4,
            proc: 2,
            period: params['period0'].to_i,
            pkind: 98,
            block: packet_id
          }
          if params['minWl0'].nil?
            @local_id+=1
            @item << Conservation::CBASE.merge(id: @local_id, code: 360101)
          end
        end
      end
      
      packet_id=@local_id
      @local_id += 1
      @item << {
        id: @local_id, 
        value: params['period0'].to_i, 
        bseq: 360102,
        code: 4193,
        units: "code table",
        "rec_flag" => 4,
        proc: 3,
        period: params['period0'].to_i,
        pkind: 98,
        block: packet_id
      }
      # Rails.logger.debug("My object+++++++++++++++++: #{@item.inspect}")
      message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], "meas_time_utc" => Time.now.strftime("%Y-%m-%d")+'T05:00', "syn_hour_utc"=>'05:00'},
        'DataList':{item: @item}}
      response_section3 = client.call(:set_data, message: message)
      response2_section3 = client2.call(:set_data, message: message)
      # if params['avgWc0'].present?
      #   @local_id+=1
      #   packet_id=@local_id
      #   @item << {id: @local_id, code: 360102}
      #   @local_id += 1
      #   @item << {id: @local_id, proc: 1, period: params['period0'], code:13193, value: params['avgWc0'], block: packet_id, "rec_flag": 3, pkind: 98}
      # end
      # if params['maxWc0'].present?
      #   @local_id+=1
      #   packet_id=@local_id
      #   @item << {id: @local_id, code: 360102}
      #   @local_id += 1
      #   @item << {id: @local_id, proc: 2, period: params['period0'], code:13193, value: params['maxWc0'], block: packet_id, "rec_flag": 3, pkind: 98}
      # end
      # if params['minWc0'].present?
      #   @local_id+=1
      #   packet_id=@local_id
      #   @item << {id: @local_id, code: 360102}
      #   @local_id += 1
      #   @item << {id: @local_id, proc: 3, period: params['period0'], code:13193, value: params['minWc0'], block: packet_id, "rec_flag": 3, pkind: 98}
      # end
      # if params['maxLevelDate'].present?
      #   @local_id+=1
      #   packet_id=@local_id
      #   @item << {id:@local_id, code: 360102}
      #   @local_id += 1
      #   @item << {
      #     id: @local_id, 
      #     "rec_flag" => 4,
      #     code: 4194,
      #     value: "#{params['maxLevelDate']} #{params['maxLevelHour']}:00:00", #"2024-07-03 14:00:00",
      #     unit: "ccitt ia5",
      #     proc: 2,
      #     period: 30,
      #     pkind: 98,
      #     block: packet_id
      #   }
      # end
    end

    if (response.success?)  # || (response_water_consumption.present? && response_water_consumption.success)
      save_stats = {response: response.body[:set_data_response], 
        response_water_consumption: response_water_consumption.present? ? response_water_consumption.body[:set_data_response]:nil,
        response_section21: response_section21.present? ? response_section21.body[:set_data_response]:nil,
        response_section22: response_section22.present? ? response_section22.body[:set_data_response]:nil,
        response_section3: response_section3.present? ? response_section3.body[:set_data_response]:nil
      }
      # if params['telegram'].present?
      #   save_stats[:message] = save_telegram(params['telegram'])
      # end
      # Rails.logger.debug("My object+++++++++++++++++: #{save_stats.inspect}")
      render json: {response: save_stats}
    else
      render json: {response: "Error"}
    end
  end
  
  def snow_prefix(id,code)
    {
      id: id,
      "rec_flag"=>1, 
      code: code,
      # proc: 21,
      # period: 1,
      # pkind: 10

    }
  end
  def terrain_type(id,value,packet_id)
    {
      id: id,
      code: 8192,
      value: value,
      block: packet_id,
      "rec_flag" => 4
    }
  end
  def snow_event_date(event_date)
    report_date = params['report_date']
    year = report_date[0,4]
    if report_date[5,2].to_i<event_date[2,2].to_i
      year = (report_date[0,4].to_i-1).to_s
    end
    return "#{year}-#{event_date[2,2]}-#{event_date[0,2]}"
  end
  def save_snow_data
    # `34622 15015 10060 21600 30100 71301=`
    if params['telegram'].present?
      telegram = params['telegram']
      @item = []
      @local_id = 1
      packet_id = 1
      groups = params['telegram'][12..-2].split(' ')
      groups.each{|g|
        case g[0]
          when '1' # снег и лед в поле
            if g[1,3] != '///'
              @item << snow_prefix(@local_id,366092)
              @local_id += 1
              @item << terrain_type(@local_id,1,packet_id)
              @local_id += 1
              value = "#{g[1]}.#{g[2,2]}"
              @item << {id: @local_id, block: packet_id, code:13013, value: value, "rec_flag"=> 3} # высота снежного покрова в поле 1xxx.
              if groups[1].present? && groups[1][0]=='2' # group2
                if groups[1][1,2]!='//' 
                  @local_id+=1
                  @item << {id: @local_id, block: packet_id, code:13117, "rec_flag"=> 3, value: groups[1][1,2]+'0'} # плотность снега в поле 2xx..
                end
                if groups[1][3,2]!='//' 
                  @local_id+=1
                  @item << {id: @local_id, block: packet_id, code:13115, "rec_flag"=> 3, value: '0.0'+groups[1][3,2]} # толщина ледяной корки в поле 2..xx
                end
              end
              @local_id+=1
              packet_id=@local_id
            end
            if g[4] != '/'
              @item << snow_prefix(@local_id,366091)
              @local_id += 1
              @item << terrain_type(@local_id,1,packet_id)
              @local_id += 1
              @item << {id: @local_id, block: packet_id, code:20192, value: g[4]+'0', "rec_flag"=> 3} # степень покрытости ледяной коркой почвы в поле 1...x
              i = telegram.index(' 3')
              if !i.nil?
                if telegram[i+5]!='/'
                  @local_id+=1
                  @item << {id: @local_id, block: packet_id, code:20193, value: telegram[i+5], "rec_flag"=> 3} # состояние почвы в поле 3...х
                end
              end
              @local_id+=1
              packet_id=@local_id
            end
          when '3'
            if g[1,3] != '///'
              @item << snow_prefix(@local_id,366093)
              @local_id += 1
              @item << terrain_type(@local_id,1,packet_id)
              @local_id += 1
              @item << {id: @local_id, block: packet_id, code:13011, value: g[1,3], "rec_flag"=> 3} # общий запас воды в снежном покрове в поле 3xxx.
              @local_id+=1
              packet_id=@local_id
            end
          when '7' # дата образования сн. покр. в поле
            @item << snow_prefix(@local_id,366094)
            @local_id += 1
            @item << terrain_type(@local_id,1,packet_id)
            @local_id += 1
            @item << {id: @local_id, block: packet_id, code:4195, value: snow_event_date(g[1,4]), "rec_flag"=> 3}
            @local_id+=1
            packet_id=@local_id
          # when '8' # дата образования сн. покр. в лесу
          when '9' # дата схода сн. покр. в поле
            @item << snow_prefix(@local_id,366095)
            @local_id += 1
            @item << terrain_type(@local_id,1,packet_id)
            @local_id += 1
            @item << {id: @local_id, block: packet_id, code:4195, value: snow_event_date(g[1,4]), "rec_flag"=> 3}
            @local_id+=1
            packet_id=@local_id
          # when '0' # дата схода сн. покр. в лесу
        end
      }
    end
    client = Savon.client(wsdl: 'http://10.54.1.31:8650/wsdl', env_namespace: 'SOAP-ENV')
    client2 = Savon.client(wsdl: 'http://10.54.1.32:8650/wsdl', env_namespace: 'SOAP-ENV')
    # Rails.logger.debug("My object+++++++++++++++++: #{@item.inspect}")
    message = {user: 'test', pass: 'test', report: {station: params['source_code'], 
      "meas_time_utc" => "#{params['report_date']}T05:00:00",
      "syn_hour_utc"=>'05:00'},
      'DataList':{item: @item}}
    response_snow = client.call(:set_data, message: message)
    response_snow2 = client2.call(:set_data, message: message)
    if (response_snow.success? && response_snow2.success?)
      save_stats = {response: response_snow.body[:set_data_response]}
      # Rails.logger.debug("My object+++++++++++++++++: #{save_stats.inspect}")
      render json: save_stats #{response: save_stats}
    else
      render json: {response: "Error"}
    end
  end

  def save_hydro_storm
    @item = []
    @local_id = 1
    packet_id = 1
    @item << {"rec_flag" => 1, code: 360002, id: @local_id} #, alarm: '3'+params['phenomenonType']}
    @local_id += 1
    @item << {
      id: @local_id, 
      "rec_flag" => 3,
      code: 20200,
      value: '3'+params['phenomenonType'], 
      block: packet_id
    }
    @local_id+=1
    packet_id=@local_id
    if params['waterLevel'].present?
      water_level_and_deviation_items(params['waterLevel'].to_f/100, params['waterLevelDeviation'].to_f/100)
    end
    if params["ip0"].present?
      @local_id+=1
      packet_id=@local_id
      @item << Conservation::CBASE.merge(id: @local_id, code: 360110)
      ip_keys = params.keys.grep(/ip/)
      ip_keys.each{|k| 
        @local_id += 1
        @item << groups15_16(packet_id,@local_id,params[k],13200)
      }
      ii_keys = params.keys.grep(/ii/)
      ii_keys.each{|k| 
        @local_id += 1
        @item << groups15_16_intens(packet_id,@local_id,params[k],13202)
      }
    end
    if params["wb0"].present?
      @local_id+=1
      packet_id=@local_id
      @item << Conservation::CBASE.merge(id: @local_id, code: 360110)
      wb_keys = params.keys.grep(/wb/)
      wb_keys.each{|k| 
        @local_id += 1
        @item << groups15_16(packet_id,@local_id,params[k],13201)
      }
      wi_keys = params.keys.grep(/wi/)
      wi_keys.each{|k| 
        @local_id += 1
        @item << groups15_16_intens(packet_id,@local_id,params[k],13203)
      }
    end
    if params["precipitation"].present?
      # if(params["precipitation"].to_i<990)
      #   val = params["precipitation"]
      # elsif (params["precipitation"].to_i==990)
      #   val = "-0.1"
      # else
      #   val = ((params["precipitation"].to_i-990).to_f/10).round(1)
      # end
      val = params["precipitation"].to_i<990? params["precipitation"] : (params["precipitation"].to_i==990? "-0.1" : ((params["precipitation"].to_i-990).to_f/10).round(1)) 
      interval = ['0','60','180','360','720']
      precipitation_and_duration_items(val,interval[params["durationPrecipitation"].to_i])
      
    end
    
    d = Time.parse("#{params['obsDate']}T#{params['obsHour'].rjust(2,'0')}:00:00").getutc()
    time_utc = d.strftime('%Y-%m-%dT%H:00:00')
    client = Savon.client(wsdl: 'http://10.54.1.30:8650/wsdl', env_namespace: 'SOAP-ENV')
    message = {user: 'test', pass: 'test', report: {station: params['hydroPostCode'], 
    "meas_time_utc" => time_utc, "syn_hour_utc"=>time_utc[11,2]+':00', alarm: '1'},
        'DataList':{item: @item}}
    # Rails.logger.debug("My object+++++++++++++++++: #{@item.inspect}")        
    response = client.call(:set_data, message: message)
    if response.success?
      save_stats = {response: response.body[:set_data_response]}
      # Rails.logger.debug("My object+++++++++++++++++: #{save_stats.inspect}")
      render json: {response: save_stats}
    else
      render json: {response: "Error"}
    end
  end
    # HHZZ 83048 19082 10130 20000 96606 10130 20480 31154 40034 51810=
    # def save_telegram telegram
    #   posts = [nil,83028,83035,83056,83060,83068,83074,83083,83478,83040,83036,83045,83050,83048,83026,78301,78413,78421,78427,78430,78434,78436]
    #   # uri = URI('http://localhost:3002/hydro_observations/create_hydro_telegram')
    #   # uri = URI('http://31.133.32.14:8080/hydro_observations/create_hydro_telegram')
    #   uri = URI('http://10.54.1.6:8080/hydro_observations/create_hydro_telegram')
    #   http = Net::HTTP.new(uri.host, uri.port)
    #   req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    #   param = {hydro_observation:
    #     {
    #       hydro_type: telegram[0,4], #'HHZZ',
    #       # hydro_post_id: posts.index(telegram[5,5].to_i),
    #       hour_obs: telegram[13,2],
    #       date_observation: Time.now.strftime('%Y-%m-%d'),
    #       content_factor: telegram[15],
    #       telegram: telegram[5..]
    #     },
    #     date: Time.now.strftime('%Y-%m-%d'),
    #     input_mode: "normal"
    #   }.to_json
    #   # Rails.logger.debug("My object+++++++++++++++++>>>>>>>>>>>>>>>>: #{http.inspect}")
    #   req.body = param
    #   res = http.request(req)
    #   # Rails.logger.debug("My object+++++++++++++++++<<<<<<<<<<<<<<<<: #{res.body}")
    #   return JSON.parse(res.body)["errors"][0]
    #   # return "Done"
    # end
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