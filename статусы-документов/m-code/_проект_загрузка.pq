let
    source = #"схема таблицы"[проект],
    select_columns = 
        Table.SelectColumns(
            source,
            {
                "проект 1с",
                "ответственный гувр цок",
                "ответственный гувр оп 1",
                "ответственный гувр оп 2",
                "ответственный гувр оп 3",
                "ответственный вкс цок",
                "ответственный вкс оп 1",
                "ответственный вкс оп 2",
                "ответственный вкс оп 3"
            }
        ),
    distinct_vals = Table.Distinct(select_columns, "проект 1с"),
    add_sort = 
        fnAddSort(
            [
                source = distinct_vals, 
                columns = {"проект 1с"}
            ]
        )
in
    add_sort
