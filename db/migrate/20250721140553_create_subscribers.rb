class CreateSubscribers < ActiveRecord::Migration[8.0]
  def change
    create_table :subscribers do |t|
      t.string :email
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end
