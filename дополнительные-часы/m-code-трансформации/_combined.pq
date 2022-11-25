let
    source = #"_get_data",
    select_data = Table.SelectColumns(source, {"имя файла", "PrepareData"}),

    expand_columns = Table.ExpandTableColumn(
        select_data, 
        "PrepareData", 
        {
            "дата",
            "проект",
            "подпроект",
            "организация",
            "классификатор",
            "работа описание",
            "работа группа",
            "типовые",
            "часы",
            "стоимость руб"
        }
    ),
    change_dtype = Table.TransformColumnTypes(
        expand_columns,
        {
            {"дата", type date}, 
            {"проект", type text}, 
            {"подпроект", type text}, 
            {"организация", type text}, 
            {"классификатор", type text}, 
            {"типовые", type text},
            {"часы", type number},
            {"стоимость руб", type number}
        }
    )
in
    change_dtype