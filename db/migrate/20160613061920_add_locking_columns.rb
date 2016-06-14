class AddLockingColumns < ActiveRecord::Migration
  def self.up
    add_column :deals, :lock_version, :integer, default: 0
  end

  def self.down
    remove_column :deals, :lock_version
  end
end
