# encoding: utf-8
class SubscriptionMailer < ActionMailer::Base

  add_template_helper(ApplicationHelper)

  default :from => "Eviterra.com <subscription@eviterra.com>", :reply_to => Conf.mail.subscription_reply_to, :bcc => Conf.mail.subscription_cc

  # FIXME надо не городить notice_info в модели, надо сразу сюда передавать destination
  # и разбирать его на месте.

  def notice(notice_info)
    @notice = notice_info
    logger.info 'Subscription: sending email ' + @notice[:email]

    subject = "#{@notice[:description]} за #{@notice[:price]}, вылет #{@notice[:from_date]}"

    mail :to => @notice[:email], :subject => subject do |format|
      format.text
    end

    StatCounters.inc %W[subscription.sent]
  end

  private

  # TODO вынести https://eviterra.com в конфиг, или, еще лучше, использовать здесь url_helper-ы
  helper_method :buy_link, :unsubscribe_link

  def unsubscribe_link
    args = { subscription: @notice[:id], email: @notice[:email] }
    "https://eviterra.com/unsubscribe/?#{args.to_query}"
  end

  def buy_link
    "https://eviterra.com/##{@notice[:query_key]}"
  end

end
