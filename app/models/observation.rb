class Observation
  attr_accessor :observations
  def initialize(q_params)
    client = Savon.client(wsdl: 'http://10.54.1.30:8650/wsdl', env_namespace: 'SOAP-ENV')
    q_params['min_quality'].present? ?
      message = {user: 'test', pass: 'test', limit: 10, 'min_quality'=> q_params['min_quality']}:
      message = {user: 'test', pass: 'test', limit: 10}
    m = message.merge(q_params)
    response = client.call(:get_data, message: m)
    if response.success?
      if response.body.present? && response.body[:get_data_response].present? && response.body[:get_data_response][:data_list].present?
        @observations = response.body[:get_data_response][:data_list][:item].is_a?(Array)? response.body[:get_data_response][:data_list][:item]:[response.body[:get_data_response][:data_list][:item]]
      else
        @observations = []
      end
    end
  end
  def observations
    @observations
  end
#  def message
#    @message
#  end
end
# • stations: 	список станций
# • streams: 	список потоков
# • sources: 	список источников
# • bseq: 		список кодов базовых последовательностей
# • codes :		список кодов BUFR
# • proc: 		список кодов признака значимости времени
# • periods: 	список значений периодов
# • pkind:		код единиц измерения периода
# • height: 	список значений высоты измерения (в метрах)
# • hashes: 	список хэшей измерения
# • units :		требуемая единица измерения 
# • before :	выдавать результаты не позже
# • after :		выдавать результаты не раньше
# • syn_hours :	синоптические сроки
# • limit :		количество результатов
# • min_quality : 	выдавать результаты с качеством не ниже указанного
# • start_id :	выдавать результаты с id не ниже указанного
# • nulls : 		включать null значения
# • local_time :	время в запросе локальное
# • verbose : 	выдавать результат вместе с цепочками
# • alarm
