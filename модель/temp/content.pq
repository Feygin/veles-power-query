let
    source = Folder.Files("\\veles-srv\Велесстрой\УМиОР\1.ОУСР\1.ГУВР\0. PBI Единая Модель"),
    filter_subfolder = Table.SelectRows(source, each [Folder Path] = "\\veles-srv\Велесстрой\УМиОР\1.ОУСР\1.ГУВР\0. PBI Единая Модель" & "\"),
    filter_temp_files = Table.SelectRows(filter_subfolder, each not Text.StartsWith([Name], "~")),
    extract_content = Table.AddColumn(filter_temp_files, "file_content", each Excel.Workbook([Content])),
    expand_content = 
        Table.ExpandTableColumn(
            extract_content, 
            "file_content", 
            {"Name", "Data", "Item", "Kind", "Hidden"}, 
            {"Name.1", "Data", "Item", "Kind", "Hidden"}
        ),
    select_attribute_columns = 
        Table.SelectColumns(
            expand_content,
            {
                "Name",
                "Kind", 
                "Item", 
                "Data" 
            }
        ),
    filter_tables = Table.SelectRows(select_attribute_columns, each [Kind] = "Table")
in
    filter_tables