/* 
    таблица с ошибками преобразования
 */
let
    fact = Table.AddColumn(#"факт", "база", each "факт"), //добавляем аттрибут с именем таблицы факт
    contract = Table.AddColumn(#"контракт", "база",  each "контракт"), //добавляем аттрибут с именем таблицы контракт
    
    fact_err_to_colls = fnCheckTableForErrors(fact, [columns = {"имя файла", "база"}]), //ошибки в таблице факт
    contract_err_to_colls = fnCheckTableForErrors(contract, [columns = {"имя файла", "база"}]), //ошибки в таблице контракт

    combine_err = Table.Combine({fact_err_to_colls, contract_err_to_colls}), //объединяем таблицы с ошибками

    filter_rows_with_errors = Table.SelectRows( //оставляем строки с ошибками
        combine_err, //если в таблице не было ошибкок - остается пустая строка
        each ([содержит ошибку] = true)
    ) 
in
    filter_rows_with_errors