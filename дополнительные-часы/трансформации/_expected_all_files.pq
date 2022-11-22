let
    source = Folder.Files(#"extra_hours_path"),
    filter_subfolders = Table.SelectRows(source, each ([Folder Path] = #"extra_hours_path" & "\")),
    filter_hidden = Table.SelectRows(filter_subfolders, each [Attributes]?[Hidden]? = false),
    select_cols = Table.SelectColumns(filter_hidden,{"Name"}),
    rename_col = Table.RenameColumns(select_cols,{{"Name", "имя файла"}})
in
    rename_col