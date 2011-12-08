# encoding: utf-8
require 'spec_helper'

describe Amadeus::Macros do
  describe "#cmd_full" do
    # надо проверить, что не обвалим обычное добавление документов, и проч.
    # нужна выборка ответов Command_CrypticReply.xml
    pending "should probably raise CommandCrypticError" do
      erroneous_reply = "/$SECURED ETKT RECORD(S)\n\n "
    end
  end
end
