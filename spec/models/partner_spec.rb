# encoding: utf-8
require 'spec_helper'
describe Partner do
  describe '#authenticate' do
    it 'does not authenticate partners with blank passwords' do
      Partner.create(:token => 'cucuziaca', :password => '', :enabled => true)
      Partner.authenticate('cucuziaca', '').should be_false
    end

    it 'does authenticate partner with normal password' do
      Partner.create(:token => 'cucuziaca', :password => 'jazzz', :enabled => true)
      Partner.authenticate('cucuziaca', 'jazzz').should be_true
    end
  end
end