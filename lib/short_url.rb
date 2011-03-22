# encoding: utf-8
module ShortUrl
  URL_CHARS = ('0'..'9').to_a + %w(b c d f g h j k l m n p q r s t v w x y z) + %w(B C D F G H J K L M N P Q R S T V W X Y Z)
  URL_BASE = URL_CHARS.size

  # а можно было сделать почти то же самое вот так:
  # id_number.to_s(36)

  def self.generate_url id_number
    local_count = id_number.abs
    result = ''
    while (local_count != 0) && (result.length < 6)
      rem = local_count % URL_BASE
      local_count = (local_count - rem) / URL_BASE
      result = URL_CHARS[rem] + result
    end
    return result
  end


  def self.random_hash p=0
    (2**25 + p.abs + rand(2**30 - 2**25)).to_s(32) # уже не всегда ровно 6 символов
  end
end

