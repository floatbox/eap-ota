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
    column :locked_at, class: "align-right"
    column :created_at, class: "align-right"
    default_actions
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

  action_item :only => :show do
    if resource.access_locked?
      link_to "Unlock", {:action => :unlock}, :method => :post
    else
      link_to "Lock", {:action => :lock}, :method => :post
    end
  end

  member_action :lock, :method => :post do
    resource.lock_access!
    redirect_to({:action => :show}, {:notice => "Locked!"})
  end

  member_action :unlock, :method => :post do
    resource.unlock_access!
    redirect_to({:action => :show}, {:notice => "Unlocked!"})
  end

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
