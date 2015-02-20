class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :screen_name
      t.string :profile_image_url_https
      t.integer :tweet_count

      t.timestamps
    end
  end
end