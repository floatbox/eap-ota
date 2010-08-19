class AmadeusCommission < ActiveRecord::Base
  belongs_to :airline

  def human
    if percentage?
      "%0.0f%%" % value
    else
      "%0.0f руб" % value
    end
  end
end
