/* 
    Цель: извлечение нескольких таблиц из файла с проверкой на их наличие
 */
(source as any, _parameter as record) =>
    let
    // [       
        kind = Record.Field(_parameter, "kind"), //"Sheet" / "Table"
        names = Record.Field(_parameter, "names"), //список таблиц, list
        file = Record.FieldOrDefault(_parameter, "file", null),

        //получаем содержимое файла
        get_source = 
            if Value.Is(source, type binary) then
                Excel.Workbook(source, null, true)
            else if Value.Is(source, type text) and Text.StartsWith(source, "http") then
                Excel.Workbook(Web.Contents(source), null, true)
            else if Value.Is(source, type text) then
                Excel.Workbook(File.Contents(source))
            else ...,
        select_tables = 
            Table.SelectRows(
                get_source,
                each ([Kind] = kind) and List.Contains(names, [Item])
            ),
        to_record =
            let
                select_cols = Table.SelectColumns(select_tables, {"Data", "Item"}),
                rename_cols = Table.RenameColumns(select_cols, {{"Data", "Value"}, {"Item", "Name"}}),
                to_record = Record.FromTable(rename_cols)
            in
                to_record,
            //пользовательские ошибки
            err = 
            [
                get_file_name = 
                    if (file <> null) then
                        file
                    else if Value.Is(source, type text) then 
                        source
                    else "#файл не задан",
                missing_tables = List.Difference(names, select_tables[Item]),
                missing_tables_text = Text.Combine(missing_tables, " ;"),
                err_missing_values = 
                    error Error.Record(
                                Text.Format(
                                    "fnGetTableFromFile: в файле: ""#{0}"" отсутствуют следующие таблицы / именованные диапазоны:" &
                                    " ""#{1}"".",
                                    {get_file_name, missing_tables_text}
                                )
                            )
            ],
        get_tables = 
            if (Table.RowCount(select_tables) = List.Count(names)) then 
                to_record
            else 
                err[err_missing_values]
    // ]
    in
        get_tables