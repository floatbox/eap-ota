# encoding: utf-8
ActiveAdmin.register Airport do
  menu parent: 'Dictionary'

  actions :all, except: [:destroy]
end
