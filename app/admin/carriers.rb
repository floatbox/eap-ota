# encoding: utf-8
ActiveAdmin.register Carrier do
  menu parent: 'Dictionary'

  actions :all, except: [:destroy]
end
