# encoding: utf-8
ActiveAdmin.register Partner do

  controller do
    def resource
      token = params[:id] == 'anonymous' ? '' : params[:id]
      Partner.where(token: token).first!
    end
  end

  scope :all, default: true
  scope :enabled
  scope :disabled

  index do
    column :token
    column :hide_income, class: 'align-center' do |resource|
      icon(:check) if resource.hide_income
    end
    column :cookies_expiry_time, class: 'align-right'
    column :income_at_least
    column :cheat_mode, class: 'align-center' do |resource|
      status_tag resource.cheat_mode
    end
    actions do |resource|
      if authorized? :enable, resource
        if resource.enabled?
          link_to "Disable", {:action => :disable, :id => resource.id}, :method => :post
        else
          link_to "Enable", {:action => :enable, :id => resource.id}, :method => :post
        end
      end
    end
  end

  form do |f|
    f.inputs :token, :password, :enabled
    f.inputs :hide_income, :cookies_expiry_time, :income_at_least, :cheat_mode, :notes
    f.actions
  end

  member_action :enable, :method => :post do
    resource.enable!
    redirect_to :back, :notice => "Enabled!"
  end

  member_action :disable, :method => :post do
    resource.disable!
    redirect_to :back, :notice => "Disabled!"
  end

  member_action :history

  action_item :only => :show do
    link_to "History", :action => :history
  end

  action_item :only => :show do
    if authorized? :enable, resource
      if resource.enabled?
        link_to "Disable", {:action => :disable}, :method => :post
      else
        link_to "Enable", {:action => :enable}, :method => :post
      end
    end
  end
end
