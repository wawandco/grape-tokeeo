class UserDataMapper
  include DataMapper::Resource

  property :id,    Serial
  property :name,  String
  property :email, String
  property :token, String
end