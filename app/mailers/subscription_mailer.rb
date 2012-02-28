# encoding: utf-8
class SubscriptionMailer < ActionMailer::Base
  @queue = :subscription
  #run queu > bundle exec rake qu:work QUEUES=subscription

  add_template_helper(ApplicationHelper)
  default :from => "Eviterra.com <ticket@eviterra.com>", :bcc => Conf.mail.subscription_cc

  def notice(notice_info)
    @notice = notice_info
    logger.info 'Subscription: sending email ' + notice_info['email']

    subject = "#{@notice['description']} за #{@notice['price']}, вылет #{@notice['from_date']}"

    mail :to => notice_info['email'], :subject => subject do |format|
      format.text
    end

    StatCounters.inc %W[subscription.sent]
  end

  def self.perform(notice_info)
    logger.info 'Subscription: sending email ' + notice_info['email']
    SubscriptionMailer.notice(notice_info).deliver
    puts "Subscription email #{notice_info['email']} to #{notice_info['description']} SENT on #{Time.now}"
    rescue
      puts "Subscription email #{notice_info['email']} to #{notice_info['description']} ERROR on #{Time.now}"
  end

end
