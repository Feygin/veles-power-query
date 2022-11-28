let
    source = Folder.Files(#"ключевые_path"),
    filter_subfolders = Table.SelectRows(source, each ([Folder Path] = #"ключевые_path" & "\")),
    filter_hidden = Table.SelectRows(filter_subfolders, each [Attributes]?[Hidden]? = false),
    select_cols = Table.SelectColumns(filter_hidden,{"Name"}),
    rename_col = Table.RenameColumns(select_cols,{{"Name", "имя файла"}}),
    add_list_with_result_sheets = Table.AddColumn(rename_col, "лист", each {"ключевые объемы", "лр по видам работ", "тех.ресурсы"}),
    expand_list = Table.ExpandListColumn(add_list_with_result_sheets, "лист")
in
    expand_list