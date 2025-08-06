class CreateAhoyMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :ahoy_messages, id: false do |t|
      t.string :id, primary_key: true
      t.string :user_type
      t.integer :user_id
      t.text :to
      t.string :mailer
      t.text :subject
      t.datetime :sent_at
      t.datetime :opened_at
      t.datetime :clicked_at

      t.timestamps null: false
    end

    add_index :ahoy_messages, [ :user_type, :user_id ]
  end
end
