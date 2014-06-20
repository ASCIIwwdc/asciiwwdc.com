Sequel.migration do
  up do
    add_column :sessions, :annotations, 'text[]'
    add_column :sessions, :timecodes, 'float[]'
  end

  down do
    drop_column :sessions, :subtitles
    drop_column :sessions, :timecodes
  end
end
