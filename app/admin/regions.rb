# encoding: utf-8
ActiveAdmin.register Region do
  menu parent: 'Dicionary'

  actions :all, except: [:destroy]
end
