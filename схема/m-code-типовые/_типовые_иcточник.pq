/* 
    загружаем таблицу типовых
 */
let
    // source = Table.PromoteHeaders(Excel.CurrentWorkbook(){[Name="типовые_padding"]}[Content], [PromoteAllScalars=true]) //для debug
    // ,
    source = 
        let
            data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "типовые"]), //извлекаем данные из соответствующего листа
            promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]), //используем первую строку листа в качестве заголовка
            replace_false_values_from_google = Table.ReplaceValue(promote_header,"-",null,Replacer.ReplaceValue,{"типовые вед поз", "добавлено гувр"}), //заменяем отсутствующие значения для tickbox на null
            filter_nulls = Table.SelectRows(replace_false_values_from_google, each ([типовые наименование источник] <> null)) //удаляем строки без значений
        in
            filter_nulls
in
    source