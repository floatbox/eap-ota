# encoding: utf-8
ActiveAdmin.register City do
  menu parent: 'Dicionary'

  actions :all, except: [:destroy]
end
