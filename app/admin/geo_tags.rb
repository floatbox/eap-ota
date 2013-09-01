# encoding: utf-8
ActiveAdmin.register GeoTag do
  menu parent: 'Dicionary'

  actions :all, except: [:destroy]
end
