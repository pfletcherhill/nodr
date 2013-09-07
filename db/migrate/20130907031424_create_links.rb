class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :parent_id
      t.integer :node_id
      t.integer :graph_id

      t.timestamps
    end
  end
end
