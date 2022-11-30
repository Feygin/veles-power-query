/* 
    Цель: создание композитного ключа
 */
(
    source,
    _parameter
)=>
    let
        columns = Record.Field(_parameter, "columns"),
        key_name = Record.Field(_parameter, "key_name"),
        missing_value = Record.FieldOrDefault(_parameter, "missing_value", "#не определен"),

        fnCombineFields = (row)=>
            let
                select_fields = Record.SelectFields(row, columns),
                values = Record.FieldValues(select_fields),
                is_all_missing = List.IsEmpty(List.Select(values, each _ <> missing_value )),
                combine = 
                if is_all_missing then
                    missing_value
                else 
                    Text.Combine(values, "_")
            in
                combine,

        add_composite_key = Table.AddColumn(source, key_name, fnCombineFields)
    in
        add_composite_key