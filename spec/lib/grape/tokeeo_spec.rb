require 'spec_helper'
require 'support/examples/api_example'

describe Grape::Tokeeo do

  def app
    APIExample.new
  end

  ['preshared', 'block'].each do |feature|
    context "##{feature} token" do
      it "should return 401 if X-Api-Token is not passed" do
        get 'block/something'
        expect(last_response.status).to eq(401)
      end

      it "should return 401 if X-Api-Token is not the same as the value user has defined" do
        get 'preshared/something', nil, { 'X-Api-Token' => 'not right' }
        expect(last_response.status).to eq(401)
      end

      it "should not affect external content" do
        get :unsecured_endpoint
        expect(JSON.parse(last_response.body)['content']).to eq('public content')
      end
    end
  end

  context "valid preshared one"do
    it "should return 200 if X-Api-Token is the same as the value user has defined" do
      get 'preshared/something', {}, {"X-Api-Token" => 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end

  context "valid block one"do
    it "should return 200 if X-Api-Token is the same as the value user has defined" do
      get 'block/something', {}, {"X-Api-Token" => 'AS0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end



end
