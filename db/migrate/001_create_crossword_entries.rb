class CreateCrosswordEntries < ActiveRecord::Migration
  def self.up
    create_table :crossword_entries do |t|
      t.string      :name
      t.string      :title
      t.string      :filename
      t.text        :crossword
      t.date        :date
      t.string      :source
      t.timestamp   :created_on
    end
    add_index :crossword_entries, :name, :unique => true
    add_index :crossword_entries, :filename, :unique => true
  end
  
  def self.down
    remove_index :crossword_entries, :name
    remove_index :crossword_entries, :filename
    drop_table :crossword_entries
  end
end
