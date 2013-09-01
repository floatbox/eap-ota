# encoding: utf-8
ActiveAdmin.register DeckUser, :as => "User" do

  actions :all, :except => [:destroy]

  # config.batch_actions = true

  scope :all
  scope :active, default: true

  filter :email
  filter :first_name
  filter :last_name

  index do
    column :email
    column :first_name
    column :last_name
    column :roles do |resource|
      resource.roles.map {|role| status_tag role }
    end
    column :status do |resource|
      status_tag resource.access_locked? ? "locked" : "active"
    end
    column :locked_at, class: "align-right"
    column :created_at, class: "align-right"
    # default_actions
    actions do |resource|
      if authorized? :lock, resource
        if resource.access_locked?
          link_to "Unlock", {:action => :unlock, :id => resource.id}, :method => :post
        else
          link_to "Lock", {:action => :lock, :id => resource.id}, :method => :post
        end
      end
    end
  end

  form do |f|
    f.inputs "Login" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.inputs "Details" do
      f.input :first_name
      f.input :last_name
    end
    f.actions
  end

  # show do
  #   render action: "show"
  # end

  action_item :only => :show do
    if authorized? :lock, resource
      if resource.access_locked?
        link_to "Unlock", {:action => :unlock}, :method => :post
      else
        link_to "Lock", {:action => :lock}, :method => :post
      end
    end
  end

  member_action :lock, :method => :post do
    resource.lock_access!
    redirect_to :back, :notice => "Locked!"
  end

  member_action :unlock, :method => :post do
    resource.unlock_access!
    redirect_to :back, :notice => "Unlocked!"
  end

  action_item :only => :show do
    link_to "History", :action => :history
  end

  # рендерит app/views/deck/users/history.html.*
  # или app/views/active_admin/resource/history.html.*
  member_action :history

  sidebar :actions, :only => :show do
    div do
      "лучше делать с помощью action_item"
    end
    div class: "action_items" do
      span class: "action_item" do
        link_to :unlock, {:action => :unlock}, :method => :post
      end
      span class: "action_item" do
        link_to :lock, {:action => :lock}, :method => :post
      end
    end
  end
end
