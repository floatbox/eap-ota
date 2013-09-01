# encoding: utf-8
ActiveAdmin.register Airplane do
  menu parent: 'Dicionary'

  actions :all, except: [:destroy]

  scope :all, default: true
  scope :autosaved
end
