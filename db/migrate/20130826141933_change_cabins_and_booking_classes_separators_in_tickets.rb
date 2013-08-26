class ChangeCabinsAndBookingClassesSeparatorsInTickets < ActiveRecord::Migration
  def up
    execute "UPDATE tickets set cabins = REPLACE(cabins, ' + ', ' '), booking_classes = REPLACE(booking_classes, ' + ', ' ')"
  end

  def down
    execute "UPDATE tickets set cabins = REPLACE(cabins, ' ', ' + '), booking_classes = REPLACE(booking_classes, ' ', ' + ')"
  end
end
