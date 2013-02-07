require 'spec_helper'

module Spree
  class GatewayWithPassword < PaymentMethod
    preference :password, :string, :default => "password"
  end
end

module Spree
  describe Admin::PaymentMethodsController do
    stub_authorization!

    let(:payment_method) { Spree::GatewayWithPassword.create!(:name => "Bogus", :preferred_password => "haxme") }

    # regression test for #2094
    it "does not clear password on update" do
      payment_method.preferred_password.should == "haxme"
      spree_put :update, :id => payment_method.id, :payment_method => { :type => payment_method.class.to_s, :preferred_password => "" }
      response.should redirect_to(spree.edit_admin_payment_method_path(payment_method))

      payment_method.reload
      payment_method.preferred_password.should == "haxme"
    end

    it "can create a payment method of a valid type" do
      expect {
        spree_post :create, :payment_method => { :name => "Test Method", :type => "Spree::Gateway::Bogus" }
      }.to change(Spree::PaymentMethod, :count).by(1)

      response.should be_redirect
      response.should redirect_to spree.edit_admin_payment_method_path(assigns(:payment_method))
    end

    it "can not create a payment method of an invalid type" do
      expect {
        spree_post :create, :payment_method => { :name => "Invalid Payment Method", :type => "Spree::InvalidType" }
      }.to change(Spree::PaymentMethod, :count).by(0)

      response.should be_redirect
      response.should redirect_to spree.new_admin_payment_method_path
    end
  end
end