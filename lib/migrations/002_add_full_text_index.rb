Sequel.migration do
  up do
    add_column :sessions, :tsv, 'TSVector'
    add_index :sessions, :tsv, type: "GIN"
    create_trigger :sessions, :tsv, :tsvector_update_trigger,
      args: [:tsv, :'pg_catalog.english', :transcript],
      events: [:insert, :update],
      each_row: true
  end

  down do
    drop_column :sessions, :tsv
    drop_index :sessions, :tsv
    drop_trigger :sessions, :tsv
  end
end