class StationMailer < ApplicationMailer
  def test_email
    attachments['bulletin.pdf'] = File.read('tmp/Bulletin_autodor_17.pdf')
    mail(to: "morgachev@dnr.mecom.ru", subject: "Бюллетень")
  end
end
