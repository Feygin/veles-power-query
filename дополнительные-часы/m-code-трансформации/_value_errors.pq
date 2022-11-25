let
    source = #"_combined",
    get_value_errors = fnCheckTableForErrors(source, [columns = {"имя файла"}]),
    filter_errors = Table.SelectRows(get_value_errors, each [содержит ошибку] = true)
in
    filter_errors