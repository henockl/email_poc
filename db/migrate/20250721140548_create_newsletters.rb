class CreateNewsletters < ActiveRecord::Migration[8.0]
  def change
    create_table :newsletters do |t|
      t.string :title
      t.text :content
      t.boolean :published
      t.date :publish_date
      t.boolean :sent

      t.timestamps
    end
  end
end
