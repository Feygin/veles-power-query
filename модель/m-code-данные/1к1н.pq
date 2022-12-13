/* 
    объединяем таблицы 1к1н из базы доп часов
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
                "File Path", 
                "Kind", 
                "Item", 
                "Data" 
            }
        ),
    filter_tables = Table.SelectRows(select_attribute_columns, each [Kind] = "Table"), //оставляем таблицы
    filter_data = Table.SelectRows(filter_tables,  each [Item] = "_1к1н"), //оставляем таблицы c rfhytnjv
    combine_tables = Table.Combine(filter_data[Data]), //объединяем таблицы
    select_columns = Table.SelectColumns( //выбираем требуемые поля
        combine_tables,
       {
            "дата",
            "проект_key",
            "организация_key", 
            "1н.часы",
            "1к.часы"
        }
    ),
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных
        select_columns,
        {
            {"дата", type date},
            {"проект_key", type text},
            {"организация_key", type text},
            {"1н.часы", type number},
            {"1к.часы", type number}
        }
    )
in
    change_dtype