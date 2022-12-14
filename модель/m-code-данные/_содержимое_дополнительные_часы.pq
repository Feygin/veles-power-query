/* 
    содержимое файлов дополнительных часов
 */
let
    source = Folder.Files("C:\Users\FeyginAS\Desktop\veles-power-quey\модель\тест\дополнительные часы"), //содержимое папки
    filter_subfolder = Table.SelectRows( //исключаем подпапки
        source, 
        each [Folder Path] = "C:\Users\FeyginAS\Desktop\veles-power-quey\модель\тест\дополнительные часы" & "\"
    ), 
    filter_temp_files = Table.SelectRows(filter_subfolder, each not Text.StartsWith([Name], "~")), //исключаем временные файлы
    extract_content = Table.AddColumn(filter_temp_files, "Data", each Excel.Workbook([Content])), //извлекаем содержимое файлов
    expand_content = //раскрываем содержимое файлов
        Table.ExpandTableColumn(
            extract_content, 
            "Data", 
            {"Name", "Data", "Item", "Kind", "Hidden"}, 
            {"Name.1", "Data", "Item", "Kind", "Hidden"}
        ),
    select_attribute_columns = //оставляем нужные аттрибуты
        Table.SelectColumns(
            expand_content,
            {
                "Name",
                "Kind", 
                "Item", 
                "Data" 
            }
        ),
    filter_tables = Table.SelectRows(select_attribute_columns, each [Kind] = "Table") //оставляем таблицы
in
    filter_tables