/* 
    извлекаем содержимое баз дополнительных часов
 */
let
    folder_content = fnGetFolderContent(#"дополнительные_часы_путь", [exclude_subfolders = true]), //извлекаем содержимое файлов в папке доп часов
    rename_file_path = Table.RenameColumns(folder_content, {{"Name", "имя файла"}}), //переименовываем поле в котором хранятся имена файлов
    trim_sheet_name = Table.TransformColumns(rename_file_path, {"Item", each Text.Trim(Text.Lower(_))}), //нормализуем имена листов и таблиц
    select_sheets = Table.SelectRows( //оставляем таблицы с дополнительными часами
        trim_sheet_name,
        each List.Contains({"доп_часы", "дополнительные_часы", "_доп_часы_шаблон"}, [Item])
            and [Kind] = "Table"
    ),
    select_columns = Table.SelectColumns(select_sheets, {"имя файла", "Item", "Data"}), //оставляем столбцы с именем файла, таблицы и содержимым
    rename_sheet_col = Table.RenameColumns(select_columns,{{"Item", "таблица"}}), //переименовываем поле которое содержим имена таблиц

    fnNormalizeHeader = (source)=> //функция для нормализации заголовков таблицы: убирает ведущие пробелы и изменяет регистр на нижний
        let
            norm_header = Table.TransformColumnNames(source, each Text.Clean(Text.Trim(Text.Lower(_))))
        in
            norm_header,
    prepare_data = Table.AddColumn(rename_sheet_col, "NormalizeHeader", each fnNormalizeHeader([Data])) //нормализуем заголовки таблиц
in
    prepare_data