# encoding: utf-8
ActiveAdmin.register Carrier do
  menu parent: 'Dicionary'

  actions :all, except: [:destroy]
end
