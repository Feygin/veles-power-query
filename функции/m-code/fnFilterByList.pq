/* 
    Цель: фильтр столбца по значениям из списка
 */
 (
    source,
    _parameter as record
 )=>
    let
        // [
        column = Record.Field(_parameter, "column"),
        filter = Record.Field(_parameter, "filter"),
        comparer = Record.FieldOrDefault(_parameter, "comparer", Comparer.OrdinalIgnoreCase),
        
        filter_buffer = List.Buffer(filter),
        filter_data =
            Table.SelectRows(
                source, 
                each List.Contains(filter_buffer, Record.Field(_, column), comparer)
            )
        // ]
    in
        filter_data