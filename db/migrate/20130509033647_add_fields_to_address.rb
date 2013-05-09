class AddFieldsToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :city, :string
    add_column :addresses, :suburb, :string
    add_column :addresses, :zipcode, :string
    add_column :addresses, :street, :string
    add_column :addresses, :streetno, :string
    add_column :addresses, :longitude, :float
    add_column :addresses, :latitude, :float
    add_column :addresses, :error_code, :string
  end
end
