require "grape/tokeeo"


class APIExample < Grape::API
  format :json

  resource :preshared_with_message do
    validate_token is: "AAA", invalid_message: 'Invalid token passed buddy'

    get :something do
      {content: 'secret content'}
    end
  end

  resource :preshared do
    validate_token is: "S0METHINGWEWANTTOSHAREONLYWITHCLIENT"

    get :something do
      {content: 'secret content'}
    end
  end

  resource :preshared_header do
    validate_token header: "X-My-Api-Header", is: "S0METHINGWEWANTTOSHAREONLYWITHCLIENT"

    get :something do
      {content: 'secret content'}
    end
  end

  resource :preshared_with_list do
    validate_token is: ["S0METHINGWEWANTTOSHAREONLYWITHCLIENT", "OTHERS0METHINGWEWANTTOSHAREONLYWITHCLIENT"]

    get :something do
      {content: 'secret content'}
    end
  end

  resource :preshared_header_with_list do
    validate_token header: "X-My-Api-Header", is: ["S0METHINGWEWANTTOSHAREONLYWITHCLIENT", "OTHERS0METHINGWEWANTTOSHAREONLYWITHCLIENT"]

    get :something do
      {content: 'secret content'}
    end
  end

  get :unsecured_endpoint do
    {content: "public content"}
  end

  resource :block do
    validate_token_with do |token|
      token.try(:start_with?, 'A')
    end

    get :something do
      {content: 'secret content'}
    end
  end

  resource :block_header do
    validate_token_with header: "X-My-Api-Header" do |token|
      token.try(:start_with?, 'A')
    end

    get :something do
      {content: 'secret content'}
    end
  end

  resource :model do
    validate_token in: User, field: :token

    get :something do
      {content: 'secret content'}
    end
  end

  resource :model_header do
    validate_token header: "X-My-Api-Header", in: User, field: :token

    get :something do
      {content: 'secret content'}
    end
  end

  resource :missing_token_message do
    validate_token is: 'AAA', missing_message: 'API token is missing'
    get :something do
      {content: 'secret content'}
    end
  end

  # validate_token in: User, field: :auth_token
  # validate_token with: do |token|
  #
  # end

end
