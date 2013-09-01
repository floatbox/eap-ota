# encoding: utf-8
ActiveAdmin.register GeoTag do
  menu parent: 'Dictionary'

  actions :all, except: [:destroy]

  scope :all, default: true
end
