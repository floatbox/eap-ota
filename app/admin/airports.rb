# encoding: utf-8
ActiveAdmin.register Airport do
  menu parent: 'Dicionary'

  actions :all, except: [:destroy]
end
