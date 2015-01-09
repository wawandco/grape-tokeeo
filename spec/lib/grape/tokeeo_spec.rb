require 'spec_helper'
require 'support/examples/api_example'

describe Grape::Tokeeo do

  def app
    APIExample.new
  end

  ['preshared', 'preshared_header', 'preshared_with_list', 'block', 'model'].each do |feature|
    context "##{feature} token" do
      it "should return 401 if X-Api-Token is not passed" do
        get "#{feature}/something"
        expect(last_response.status).to eq(401)
      end

      it "should return 401 if header name is not the same as the value user has defined" do
        get "#{feature}/something", nil, { 'Not-Header-Name' => 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT' }
        expect(last_response.status).to eq(401)
      end

      it "should return 401 if X-Api-Token is not the same as the value user has defined" do
        get "#{feature}/something", nil, { 'X-Api-Token' => 'not right' }
        expect(last_response.status).to eq(401)
      end

      it "should not affect external content" do
        get :unsecured_endpoint
        expect(JSON.parse(last_response.body)['content']).to eq('public content')
      end
    end
  end

  context "valid preshared one" do
    it "should return 200 if X-Api-Token is the same as the value user has defined" do
      get 'preshared/something', {}, {'X-Api-Token' => 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end

  context "valid preshared with list one" do
    it "should return 200 if X-Api-Token exist in the list that user has defined" do
      get 'preshared_with_list/something', {}, {'X-Api-Token' => 'OTHERS0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end

  context "valid block one" do
    it "should return 200 if X-My-Api-Header is the same as the value user has defined" do
      get 'block/something', {}, {"X-Api-Token" => 'AS0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end

  context "valid model one" do
    it "should return 200 if X-Api-Token is the same as the value user has defined" do
      create(:user, token: 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT')
      get 'model/something', {}, {"X-Api-Token" => 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end

  context "custom_error_message" do
    it "should return current message if X-Api-Token is not user-defined" do
      get 'preshared_with_message/something', {}, {"X-Api-Token" => 'AAB'}
      expect(JSON.parse(last_response.body)['error']).to eq("Invalid token passed buddy")
    end
  end

  context "preshared header one" do
    it "should return 200 if X-My-Api-Header is the same as the value user has defined" do
      get 'preshared_header/something', {}, {"X-My-Api-Header" => 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end

  context "valid preshared with list one" do
    it "should return 200 if X-My-Api-Header exist in the list that user has defined" do
      get 'preshared_header_with_list/something', {}, {'X-My-Api-Header' => 'OTHERS0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end

  context "valid model one" do
    it "should return 200 if X-My-Api-Header is the same as the value user has defined" do
      create(:user, token: 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT')
      get 'model_header/something', {}, {"X-My-Api-Header" => 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end

  context "valid block one" do
    it "should return 200 if X-My-Api-Header is the same as the value user has defined" do
      get 'block_header/something', {}, {"X-My-Api-Header" => 'AS0METHINGWEWANTTOSHAREONLYWITHCLIENT'}
      expect(last_response.status).to eq(200)
    end
  end

  context "custom token is missing message" do
    it "should return token is missing message if X-Api-Token is not passed" do
      get 'missing_token_message/something'
      expect(JSON.parse(last_response.body)['error']).to eq('API token is missing')
    end
  end
end
