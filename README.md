# Grape::Tokeeo


Grape::Tokeeo is an extension to the grape gem that provides simple header-based Token authentication for API.

## Installation
Add this line to your application's Gemfile:
```
gem 'grape-tokeeo'
```
And then execute:
```
$ bundle
```
Or install it yourself as:
```
$ gem install grape-tokeeo
```

## Usage

One of the common things we do when implementing API's is to secure those, one of the kind of security implementations we can do is token-based authentication, where the client should pass some tokens based on the requests he is trying to do.

Lets say we have an API in app/api/my_api.rb

```ruby
class MyApi::API < Grape::API
  get :something do
    {content: 'secret content'}
  end
end
```
### Pre-shared token

And we don't want to expose :something publicly, grape-tokkeo helps us by allowing to ensure a valid token is being passed to the request on the X-Api-Token header, our secure API would look like:

```ruby
class MyApi::API < Grape::API
  ensure_token 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT'

  get :something do
    {content: 'secret content'}
  end
end
```

In case we call the API without passing X-Api-Token with the 'S0METHINGWEWANTTOS..' value, we will get a 401 error code on the response and our 'secret content' wont be returned to the client requesting.



