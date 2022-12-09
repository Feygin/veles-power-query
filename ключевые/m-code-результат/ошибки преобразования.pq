/* 
    выводим в отдельный шаг ошибки в данных
    они могут быть в исходниках или gjzdbnmcz при трансформациях
    нпример, при изменении типа данных: number_from('text') -> err
 */
let
    
    amt_err = fnCheckTableForErrors(#"ключевые объемы", [columns = {"имя файла", "имя листа"}]),
    manhours_err = fnCheckTableForErrors(#"ключевые часы", [columns = {"имя файла", "имя листа"}]),
    machinery_err = fnCheckTableForErrors(#"ключевые техника", [columns = {"имя файла", "имя листа"}]),

    combine_err = Table.Combine({amt_err, manhours_err, machinery_err}),

    filter_rows_with_errors = Table.SelectRows(combine_err, each ([содержит ошибку] = true))
in
    filter_rows_with_errors