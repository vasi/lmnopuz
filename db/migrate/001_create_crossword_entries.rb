class CreateCrosswordEntries < ActiveRecord::Migration
  def self.up
    create_table :crossword_entries do |t|
      t.string      :name
      t.string      :filename
      t.text        :crossword
      t.timestamp   :created_on
    end
    add_index :crossword_entries, :name
  end
  
  def self.down
    remove_index :crossword_entries, :name
    drop_table :crossword_entries
  end
end
