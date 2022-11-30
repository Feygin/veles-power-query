let
    source = #"_проект_загрузка",
    select_cols = 
        Table.SelectColumns(
            source, 
            {
                "проект 1с",
                "ответственный гувр цок",
                "ответственный вкс цок",
                "проект 1с_sort"
            }
        )
in
    select_cols