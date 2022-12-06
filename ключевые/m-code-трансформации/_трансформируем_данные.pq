/* 
    извлекаем содержимое файлов с ключевыми объемами,
    создаем функцию для первичной предобработки таблиц с ключевыми и применяем ее
 */
let
    folder_content = fnGetFolderContent(#"ключевые_путь", [exclude_subfolders = true]), //извлекаем содержимое папки с файлами ключевых (без вложенных папок)  
    rename_attributes = Table.RenameColumns(folder_content, {{"Name", "имя файла"}, {"Item", "лист"}}), //переименовываем поля таблицы с извлечением
    trim_sheet_name = Table.TransformColumns(rename_attributes, {"лист", each Text.Trim(Text.Lower(_))}), //нормализуем имена листов
    select_sheets = Table.SelectRows( //оставляем листы с данными ключевых показателей
        trim_sheet_name,
        each List.Contains({"ключевые объемы", "лр по видам работ", "тех.ресурсы"}, [лист])
            and [Kind] = "Sheet"
    ),
    select_columns = Table.SelectColumns(select_sheets, {"имя файла", "лист", "Data"}), //оставляем метаданные таблиц и их содержимое
  
    /* 
        функция по предобработке данных с ключевыми показателями
     */
    fnUnpivot = 
        (source, columns) =>
            let
                // [ //для debug
                replace_erors = fnReplaceAllErrors(source), //заменяем все ошибки в файле
                promote_header = Table.PromoteHeaders(replace_erors, [PromoteAllScalars = true]),//поднимаем первую строку в заголовок
                normalize_header = Table.TransformColumnNames(promote_header, each Text.Trim(Text.Lower(_))),//нормализуем заголовки
                cur_columns = Table.ColumnNames(normalize_header),//текущий список солбцов
                columns_with_name = List.Select(cur_columns, each not Text.StartsWith(_, "column")),//список столбцов для которых пользователь задал значения
                select_named_columns = Table.SelectColumns(normalize_header, columns_with_name),//оставляем столбцы выбранные пользователем
                fill_down = Table.FillDown(select_named_columns, columns), //протягиваем значения по основным столбцам
                filter_rows = Table.SelectRows(fill_down, each ([фильтр] <> null)), //фильтруем строки выбранные пользователем
                remove_filter_column = Table.RemoveColumns(filter_rows,{"фильтр"}), //удаляем столбец с фильтром
                unpivot = Table.UnpivotOtherColumns(remove_filter_column, columns, "дата", "Value"), //выполняем unpivot
                filter_zero_amt = Table.SelectRows(unpivot, each ([Value] <> 0 and [Value] <> null)) //фильтруем нулевые значения
                // ]
            in
                filter_zero_amt
                ,
    unpivot = Table.AddColumn( //применяем функцию к данным с ключевыми показателями
        select_columns, 
        "Unpivot", 
        each 
            if [лист] = "ключевые объемы" then //для каждого листа задаем соответствующий список столбцов
                fnUnpivot([Data], {"проект", "подпроект", "ключевые", "организация", "ед изм"}) //в остальном: преобразование для всех таблиц одинаковое
            else if [лист] = "лр по видам работ" then
                fnUnpivot([Data], {"проект", "подпроект", "ключевые", "ключевые ед изм", "организация", "ед изм"})
            else if [лист] = "тех.ресурсы" then
                fnUnpivot([Data], {"проект", "подпроект", "вид техники", "ед изм"})
            else
                ...
    )
in
    unpivot