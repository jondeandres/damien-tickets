require 'pony'
require 'uri'
require 'net/http'
require 'logger'

class Checker
  URL = 'http://www.reallyusefultheatres.co.uk/buy-tickets'
  EMAILS = 'jondeandres@gmail.com; igayoso@gmail.com'

  attr_reader :uri
  attr_writer :logger

  def initialize
    @uri = URI(URL)
    @logger = Logger.new(STDOUT)
  end

  def start
    loop(&job)
  end

  def job
    proc do
      begin
        notice_and_exit if on_sale?
        sleep 10
      rescue => e
        @logger.error(e.to_s)
        send_mail(e.to_s, subject: 'Error checking tickets!')
        sleep 120
      end
    end
  end

  def notice_and_exit
    message = 'Tickets on sale!!'
    send_mail(URL, subject: message)
    @logger.info(message)
    exit(1)
  end

  def on_sale?
    @logger.info('Checking Damien Rice tickets in London...')

    html = Net::HTTP.get(uri.host, uri.path)
    html.scan(/Damien|damien/).any?
  end

  def send_mail(body, options)
    Pony.mail(options.merge(to: EMAILS, body: body, from: 'no-reply@damienchecker.com').merge(mail_options))
  end

  private

  def mail_options
    {}
  end
end
