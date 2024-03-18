class Observation
  attr_accessor :observations
  def initialize(q_params)
    client = Savon.client(wsdl: 'http://10.54.1.32:8650/wsdl', env_namespace: 'SOAP-ENV')
    message = {user: 'test', pass: 'test', limit: 10}
    message.merge(q_params)
    response = client.call(:get_data, message: message)
    if response.success?
      @observations = response.body[:get_data_response][:data_list][:item]
    end
  end
  def observations
    @observations
  end
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