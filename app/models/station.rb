class Station
  attr_accessor :stations
  def initialize
    client = Savon.client(wsdl: 'http://10.54.1.32:8650/wsdl', env_namespace: 'SOAP-ENV')
    response = client.call(:get_station_list, message: {user: 'test', pass: 'test'})
    if response.success?
      @stations = response.body[:get_station_list_response][:station_list][:item]
    end
  end

  def meteostations
    @stations.select{|s| s if ((s[:index].to_i>34000 && s[:index].to_i<35000) || s[:index].to_i == 99023) }
  end

  def hydroposts
    @stations.select{|s| s if (s[:index].to_i>83000 && s[:index].to_i<84000) }
  end
end