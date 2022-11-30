/* 
    Функция для фильтрации таблицы по текстовому условию
*/
    (source as table, _parameter as record) =>
        let
            filter = Record.Field(_parameter, "filter"),

            filter_rows = 
                Table.SelectRows(
                    source,
                    (row)=> Expression.Evaluate(filter, Record.Combine({#shared, [row=row]}))
                )
        in
            filter_rows