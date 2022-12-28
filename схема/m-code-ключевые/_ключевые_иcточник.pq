/* 
    загружаем таблицу ключевых
 */
let
    source = Table.PromoteHeaders(Excel.CurrentWorkbook(){[Name="ключевые_padding"]}[Content], [PromoteAllScalars=true]) //для debug
    // source = 
    //     let
    //         data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "ключевые"]), //извлекаем данные из соответствующего листа
    //         promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]), //используем первую строку листа в качестве заголовка
    //         replace_false_values_from_google = Table.ReplaceValue(promote_header,"-",null,Replacer.ReplaceValue,{"ключевые вед поз", "типовые вед поз"}), //заменяем отсутствующие значения для tickbox на null
    //         filter_nulls = Table.SelectRows(replace_false_values_from_google, each ([ключевые наименование источник] <> null)) //удаляем строки без значений
    //     in
    //         filter_nulls
in
    source