# encoding: utf-8

require 'resolv'

# проверяет на наличие MX записей в dns
class MxRecordValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)

    return true unless value

    domain = value.split('@').last
    mail_servers = Resolv::DNS.open do |dns|
      dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
    end

    if mail_servers.empty?
      record.errors.add(attribute, "Указанный адрес электронной почты не существует!")
    end
  rescue Resolv::ResolvError, Resolv::ResolvTimeout => e
    # если не смогли отрезолвить, лучше пропустить потенциально дефективный ящик
    with_warning(e)
    true
  end

end

