/* 
    Цель: множественная замена значений по столбцам, по дефолту заменяет null и текстовые репрезентации ошибок на "#не определен"
 */
 (
    source as any, 
    _parameter as record //параметры
)=>
    let
        columns = Record.Field(_parameter, "columns"),
        replacement = Record.Field(_parameter, "replacement"),

        fnReplacer = 
            (v,o,n)=> 
                List.ReplaceMatchingItems(
                    {v},
                    replacement
                ){0},
        replace = Table.ReplaceValue(source, null, null, fnReplacer, columns)
    in
        replace