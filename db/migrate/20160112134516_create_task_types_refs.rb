class CreateTaskTypesRefs < ActiveRecord::Migration
  def change
    create_table :task_types_refs do |t|
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end

