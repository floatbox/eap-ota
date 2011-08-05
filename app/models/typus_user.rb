# encoding: utf-8
class TypusUser < ActiveRecord::Base

  enable_as_typus_user

  # чтоб работали старые пароли. в новом typus "--#{salt}--#{string}--"
  def encrypt(string)
    generate_hash("--#{salt}--#{string}")
  end

end
