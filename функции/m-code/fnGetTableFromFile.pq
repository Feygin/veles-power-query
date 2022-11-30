/* 
    Цель: извлечение таблицы из файла с проверкой на ее наличие
 */
(source as any, _parameter as record) =>
    let
    // [
        kind = Record.Field(_parameter, "kind"), //"Sheet" / "Table"
        name = Record.Field(_parameter, "name"), //имя листа / таблицы
        file = Record.FieldOrDefault(_parameter, "file", null), //имя файла, для генерации ошибки

        //получаем содержимое файла
        get_source = 
            if Value.Is(source, type binary) then
                Excel.Workbook(source, null, true)
            else if Value.Is(source, type text) and Text.StartsWith(source, "http") then
                Excel.Workbook(Web.Contents(source), null, true)
            else if Value.Is(source, type text) then
                Excel.Workbook(File.Contents(source))
            else ...,
        get_table = get_source{[Kind = kind, Item = name]}[Data],
        //пользовательские ошибки
        err =
            [
                get_file_name = 
                    if (file <> null) then
                        file
                    else if Value.Is(source, type text) then 
                        source
                    else 
                        "#файл не задан",
                err_missing_values = 
                    error Error.Record(
                                Text.Format(
                                    "fnGetTableFromFile: в файле: ""#{0}"" отсутствуют следующие листы / таблицы:" &
                                    " ""#{1}"".",
                                    {get_file_name, name}
                                )
                            )
            ],
        result = 
            if (try get_table)[HasError] then 
                err[err_missing_values]
            else 
                get_table
    // ]
    in
        result