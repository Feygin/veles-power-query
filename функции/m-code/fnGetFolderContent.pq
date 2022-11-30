/* 
    Цель: получение содержимого файлов из папки с заданным путем folder_path
 */
 (
    source as text,
    _parameter as record
 )=>
let
    // [
    exclude_subfolders = Record.FieldOrDefault(_parameter, "exclude_subfolders", true),

    data = Folder.Files(source),
    filter_subfolder = 
        if exclude_subfolders = true then
            Table.SelectRows(data, each [Folder Path] = source & "\")
        else 
            data,
    filter_temp_files = Table.SelectRows(filter_subfolder, each not Text.StartsWith([Name], "~")),
    add_col_with_file_path = Table.AddColumn(filter_temp_files, "File Path", each Text.Combine({[Folder Path], [Name]}, ""), type text),
    extract_content = Table.AddColumn(add_col_with_file_path, "Data", each Excel.Workbook([Content])),
    expand_content = 
        Table.ExpandTableColumn(
            extract_content, 
            "Data", 
            {"Name", "Data", "Item", "Kind", "Hidden"}, 
            {"Name.1", "Data", "Item", "Kind", "Hidden"}
        ),
    select_attribute_columns = 
        Table.SelectColumns(
            expand_content,
            {
                "Name",
                "File Path", 
                "Kind", 
                "Item", 
                "Data" 
            }
        )
    // ]
in
    select_attribute_columns