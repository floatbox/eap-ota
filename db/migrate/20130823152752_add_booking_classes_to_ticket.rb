class AddBookingClassesToTicket < ActiveRecord::Migration
  # update tickets set booking_classes = cabins;
  def change
    add_column :tickets, :booking_classes, :string
  end
end
