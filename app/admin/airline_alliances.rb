# encoding: utf-8
ActiveAdmin.register AirlineAlliance do
  menu parent: 'Dictionary'

  actions :all, except: [:destroy]
end
