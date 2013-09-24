Sequel.migration do
  up do
    create_table :sessions do
      primary_key :id
      
      varchar   :title,       empty: false
      text      :description
      text      :transcript
      text      :markup
      integer   :year,        null: false
      integer   :number,      null: false
      varchar   :track
      interval  :duration
    end
  end
  
  down do
    drop_table :sessions
  end
end