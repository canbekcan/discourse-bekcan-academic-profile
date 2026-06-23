class CreateAcademicProfileFields < ActiveRecord::Migration[7.0]
  def change
    create_table :academic_profile_fields do |t|
      t.integer :user_id, null: false
      t.string :academic_title
      t.string :main_field
      t.text :sub_fields
      t.string :orcid_id
      t.timestamps
    end
    add_index :academic_profile_fields, :user_id, unique: true
    add_index :academic_profile_fields, :orcid_id, unique: true
  end
end