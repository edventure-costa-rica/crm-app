class RenamePassportFieldsOnPerson < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.rename :passport_number, :passport
      t.rename :passport_country, :country
    end
  end

  def self.down
    change_table :people do |t|
      t.rename :passport, :passport_number
      t.rename :country, :passport_country
    end
  end
end
