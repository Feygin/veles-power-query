let
    source = Table.Buffer(Excel.CurrentWorkbook(){[Name="нормализация"]}[Content]),
    normalize = Table.TransformColumns(
        source,{
            {"поле", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"значение отчет ключевых", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"значение схема", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
        }
    ),
    remove_nulls = Table.SelectRows(
        normalize, 
        each [значение отчет ключевых] <> null 
            and [значение отчет ключевых] <> ""
            and [значение схема] <> null
            and [значение схема] <> ""
    ),
    distinct = Table.Distinct(remove_nulls,"значение отчет ключевых"),
    filter_project = Table.SelectRows(distinct, each [поле] = "организация"),
    remove_cols = Table.RemoveColumns(filter_project,{"поле"}),
    to_list = Table.ToRows(remove_cols)
in
    to_list