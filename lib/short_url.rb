module ShortUrl
  URL_CHARS = ('0'..'9').to_a + %w(b c d f g h j k l m n p q r s t v w x y z) + %w(B C D F G H J K L M N P Q R S T V W X Y Z - _)
  URL_BASE = URL_CHARS.size

  def self.generate_url idNumber
    localCount = idNumber.abs
    result = '';
    while (localCount != 0) && (result.length < 6)
      rem = localCount % URL_BASE
      localCount = (localCount - rem) / URL_BASE
      result = URL_CHARS[rem] + result
    end
    return result
  end
end