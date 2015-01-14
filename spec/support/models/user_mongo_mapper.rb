class UserMongoMapper
  include MongoMapper::Document

  key :name,  String
  key :email, String
  key :token, String
end