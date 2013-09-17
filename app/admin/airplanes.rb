# encoding: utf-8
ActiveAdmin.register Airplane do
  menu parent: 'Dictionary'

  actions :all, except: [:destroy]

  scope :all, default: true
  scope :autosaved
end
