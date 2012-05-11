require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'yajl'
Dir.chdir(Rails.root)

Daemons.run_proc('/tmp/rambler_daemon') do
  if Conf.api.send_to_rambler
    logger = ActiveSupport::BufferedLogger.new(Rails.root + 'log/rambler.log')
    db = Mongoid.master
    coll = db.collection('rambler_caches')
    cursor = Mongo::Cursor.new(coll, :tailable => true)
    data_to_send = []
    loop do
      if doc = cursor.next_document
        pricer_form = PricerForm.find doc['pricer_form_id']
        data_to_send << {:request => pricer_form.hash_for_rambler, :variants => doc['data']}
        if data_to_send.size >= Conf.api.rambler_hash_size
          json_string = Yajl::Encoder.encode(data_to_send)
          begin
            #response = HTTParty.post(Conf.api.rambler_url, :body => json_string, :format => :json)
            logger.info "Rambler api: request with #{data_to_send.count} searches sent"
          rescue Exception => e
            logger.error "Problem sending rambler hash: #{e.message}"
          end
          data_to_send = []
        end
      else
        sleep 1
        logger.info 'Nothing to send'
      end
    end
  end
end
