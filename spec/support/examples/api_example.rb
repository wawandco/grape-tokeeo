require "grape/tokeeo"


class APIExample < Grape::API
  format :json

  resource :preshared do
    ensure_token is: "S0METHINGWEWANTTOSHAREONLYWITHCLIENT"

    get :something do
      {content: 'secret content'}
    end
  end

  get :unsecured_endpoint do
    {content: "public content"}
  end


  resource :block do
    ensure_token_with do |token|
      token.try(:start_with?, 'A')
    end

    get :something do
      {content: 'secret content'}
    end
  end
  # ensure_token in: User, field: :auth_token
  # ensure_token with: do |token|
  #
  # end

end
