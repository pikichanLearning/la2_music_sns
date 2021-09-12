class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.references :user
      t.text :text
      t.string :song_artist
      t.string :song_album
      t.text :song_icon
      t.string :song_title
      t.text :song_sample
      t.timestamps null: false
    end
  end
end
