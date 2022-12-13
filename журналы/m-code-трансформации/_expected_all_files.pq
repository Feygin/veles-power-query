let
    source = Folder.Files(#"журналы_путь"),
    filter_subfolders = Table.SelectRows(source, each ([Folder Path] = #"журналы_путь" & "\")),
    filter_hidden = Table.SelectRows(filter_subfolders, each [Attributes]?[Hidden]? = false),
    select_cols = Table.SelectColumns(filter_hidden,{"Name"}),
    rename_col = Table.RenameColumns(select_cols,{{"Name", "имя файла"}}),
    norm_names = Table.TransformColumns(
        rename_col,
        {
            {"имя файла", each Text.Trim(Text.Lower(_))}
        }
    ),
    add_result_sheet = Table.AddColumn(norm_names, "лист", each #"PrSheetName")
in
    add_result_sheet