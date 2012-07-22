# encoding: utf-8
class SubscriptionMailer < ActionMailer::Base

  add_template_helper(ApplicationHelper)

  default :from => "Eviterra.com <ticket@eviterra.com>"#, :bcc => Conf.mail.subscription_cc

  def notice(notice_info)
    @notice = notice_info
    logger.info 'Subscription: sending email ' + @notice[:email]

    subject = "#{@notice[:description]} за #{@notice[:price]}, вылет #{@notice[:from_date]}"

    mail :to => notice_info[:email], :subject => subject do |format|
      format.text
    end

    StatCounters.inc %W[subscription.sent]
  end

end
