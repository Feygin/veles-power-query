let
    source = #"_проект_загрузка",
    select_cols = 
        Table.SelectColumns(
            source, 
            {
                "проект 1с",
                "ответственный гувр оп 1",
                "ответственный гувр оп 2",
                "ответственный гувр оп 3",
                "ответственный вкс оп 1",
                "ответственный вкс оп 2",
                "ответственный вкс оп 3"
            }
        ),
    unpivot_cols = 
        Table.UnpivotOtherColumns(
            select_cols, 
            {"проект 1с"}, 
            "отдел", "ответственный оп"
        ),
    fnExtractGroup = 
        (val)=>
            if Text.Contains(val, "гувр") then 
                "гувр"
            else if Text.Contains(val, "вкс") then 
                "вкс"
            else
                null,
    remove_temp_col = Table.TransformColumns(unpivot_cols, {"отдел", fnExtractGroup})
in
    remove_temp_col