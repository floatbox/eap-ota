# for 1.8.7
class Hash
  def rassoc(key)
    to_a.rassoc(key)
  end if RUBY_VERSION < "1.9"
end
