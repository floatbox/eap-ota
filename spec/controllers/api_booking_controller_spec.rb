require 'spec_helper'

describe ApiBookingController do
  describe "authorization" do
    before do
      @token = 'test_token'
      @pass = '123456'
      @partner = create(:partner, password: @pass, token: @token)
    end

    it "should correctly authorize partner" do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(@token, @pass)
      ApiBookingController.any_instance.stub(:create).and_raise('Yay')
      expect { post :create }.to raise_error /Yay/
      expect(controller.context.partner).to eq(@partner)
    end

    it "should block unauthorized requests" do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("wrong", "creds")
      post :create
      expect(response.status).to eq(401)
      expect(controller.context.partner).to eq(Partner.anonymous)
    end
  end

end
