class SetProcessedToTrueInTickets < ActiveRecord::Migration
  def up
    execute('UPDATE tickets SET processed = 1 where kind = "ticket"')
  end

  def down
  end
end
