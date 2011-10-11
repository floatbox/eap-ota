# encoding: utf-8
class SubscriptionMailer < ActionMailer::Base
  
  add_template_helper(ApplicationHelper)
  default :from => "Eviterra.com <ticket@eviterra.com>", :bcc => Conf.mail.ticket_cc

  def process(destination_id)
      mail :to => 'arefiev@gmail.com', :subject => 'subject' do |format|
      format.html { render :text => destination_id }
    end
  end

  def self.perform(destination_id)
    presentation = new SubscriptionMailer
    presentation.process(destination_id)
  end

end
