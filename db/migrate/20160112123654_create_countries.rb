class CreateCountries < ActiveRecord::Migration
  def change
    ## Create country table
    create_table :countries do |t|
      t.column :iso, :string, :size => 2
      t.column :name, :string, :size => 80
      t.column :printable_name, :string, :size => 80
      t.column :iso3, :string, :size => 3
      t.column :numcode, :integer
      t.timestamps
    end

  end
end
