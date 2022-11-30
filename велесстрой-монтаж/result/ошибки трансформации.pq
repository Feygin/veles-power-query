let
    fact_err = Table.AddColumn(
        Table.SelectRowsWithErrors(#"факт"),
        "база", 
        each "факт"
    ),
    contract_err = Table.AddColumn(
        Table.SelectRowsWithErrors(#"контракт"),
        "база", 
        each "контракт"
    ),
    
    fact_err_to_colls = fnCheckTableForErrors(fact_err, [columns = {"имя файла", "база"}]),
    contract_err_to_colls = fnCheckTableForErrors(contract_err, [columns = {"имя файла", "база"}]),

    combine_err = Table.Combine({fact_err_to_colls, contract_err_to_colls}),

    filter_rows_with_errors = Table.SelectRows(combine_err, each ([содержит ошибку] = true))
in
    filter_rows_with_errors