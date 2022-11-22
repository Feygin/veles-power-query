let
    folder_content = fnGetFolderContent(#"extra_hours_path", [exclude_subfolders = true]),
    rename_file_path = Table.RenameColumns(folder_content, {{"Name", "имя файла"}}),
    trim_sheet_name = Table.TransformColumns(rename_file_path, {"Item", each Text.Trim(Text.Lower(_))}),
    select_sheets = Table.SelectRows(
        trim_sheet_name,
        each List.Contains({"доп_часы", "дополнительные_часы", "_доп_часы_шаблон"}, [Item])
            and [Kind] = "Table"
    ),
    select_columns = Table.SelectColumns(select_sheets, {"имя файла", "Item", "Data"}),
    rename_sheet_col = Table.RenameColumns(select_columns,{{"Item", "таблица"}}),

    fnPrepareData = (source)=>
        let
            norm_header = Table.TransformColumnNames(source, each Text.Clean(Text.Trim(Text.Lower(_))))
        in
            norm_header,
    extract_data = Table.AddColumn(rename_sheet_col, "PrepareData", each fnPrepareData([Data]))
in
    extract_data