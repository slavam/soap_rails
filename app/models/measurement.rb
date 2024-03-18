class Measurement
  attr_accessor :measurements
  def initialize
    client = Savon.client(wsdl: 'http://10.54.1.32:8650/wsdl', env_namespace: 'SOAP-ENV')
    response = client.call(:get_meas_list, message: {user: 'test', pass: 'test'})
    if response.success?
      @measurements = response.body[:get_meas_list_response][:meas_type_list][:item]
    end
  end

  def measurements
    @measurements
  end
end