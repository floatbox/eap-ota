# encoding: utf-8
ActiveAdmin.register AirlineAlliance do
  menu parent: 'Dicionary'

  actions :all, except: [:destroy]
end
