class UpdateVatFieldInTickets < ActiveRecord::Migration
  def up
    Ticket.update_all('vat_status = "18%_old"', 'vat_status = "18%"')
  end

  def down
    Ticket.update_all('vat_status = "18%"', 'vat_status = "18%_old"')
  end
end
