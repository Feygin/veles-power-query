let
    amt_err = Table.AddColumn(
        Table.SelectRowsWithErrors(#"ключевые объемы"),
        "лист", 
        each "ключевые объемы"
    ),
    manhours_err = Table.AddColumn(
        Table.SelectRowsWithErrors(#"ключевые часы"),
        "лист", 
        each "лр по видам работ"
    ),
    machinery_err = Table.AddColumn(
        Table.SelectRowsWithErrors(#"ключевые техника"),
        "лист", 
        each "тех.ресурсы"
    ),
    
    amt_err_to_colls = fnCheckTableForErrors(amt_err, [columns = {"имя файла", "лист"}]),
    manhours_err_to_colls = fnCheckTableForErrors(manhours_err, [columns = {"имя файла", "лист"}]),
    machinery_err_to_colls = fnCheckTableForErrors(machinery_err, [columns = {"имя файла", "лист"}]),

    combine_err = Table.Combine({amt_err_to_colls, manhours_err_to_colls, machinery_err_to_colls}),

    filter_rows_with_errors = Table.SelectRows(combine_err, each ([содержит ошибку] = true)),
    expand_details = Table.ExpandRecordColumn(filter_rows_with_errors, "детали", {"Operator", "Left", "Right"}, {"оператор", "левый", "правый"})
in
    expand_details