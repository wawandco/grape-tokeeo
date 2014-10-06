[![Build Status](https://travis-ci.org/wawandco/grape-tokeeo.svg?branch=master)](https://travis-ci.org/wawandco/grape-tokeeo)
[![Code Climate](https://codeclimate.com/github/wawandco/grape-tokeeo/badges/gpa.svg)](https://codeclimate.com/github/wawandco/grape-tokeeo)
[![Test Coverage](https://codeclimate.com/github/wawandco/grape-tokeeo/badges/coverage.svg)](https://codeclimate.com/github/wawandco/grape-tokeeo)

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
  ensure_token is: 'S0METHINGWEWANTTOSHAREONLYWITHCLIENT'

  get :something do
    {content: 'secret content'}
  end
end
```

In case we call the API without passing *X-Api-Token* with the 'S0METHINGWEWANTTOS..' value, we will get a 401 error code on the response and our 'secret content' wont be returned to the client requesting.

### Token on model

In case we want to ensure the token exists in a model we can use the following syntax for the *ensure_token* method:

```ruby
class MyApi::API < Grape::API
  ensure_token in: SecureTokenHolder, field: :token

  get :something do
    {content: 'secret content'}
  end
end
```

Again this should ensure the token exist by looking on the SecureTokenHolder model table for a record with the column 'token' with the same value as 'X-Api-Token'.

### Token validated against a block passed

There may be some cases where you would like to do the validation by yourself or the validation logic is not simple as verifying against the model attribute, in that case we could pass a block to the *ensure_token_in* method like:

```ruby
class MyApi::API < Grape::API
  ensure_token_with do |token|
    SomeComplexOperationHolder.validate token
  end

  get :something do
    {content: 'secret content'}
  end
end
```

In this case if the result of the block is true request will bypass the token control.
