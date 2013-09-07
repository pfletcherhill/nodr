class Link < ActiveRecord::Base
  
  attr_accessible :parent_id, :node_id, :graph_id
  
  belongs_to :parent, foreign_key: :parent_id, class_name: "Node"
  belongs_to :child, foreign_key: :child_id, class_name: "Node"
  belongs_to :graph
  
end
