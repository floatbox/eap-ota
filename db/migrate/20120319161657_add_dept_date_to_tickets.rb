class AddDeptDateToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :dept_date, :date
  end
end
