class AddInReplyToUsers < ActiveRecord::Migration
  def change
    add_column :microposts, :to_id, :integer, default: nil
  end
end
