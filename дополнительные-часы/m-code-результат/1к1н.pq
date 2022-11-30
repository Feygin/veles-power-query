/* 

 */
let
    source = #"_присоединяем_схему", //ссылка на предыдущий шаг
    filter_1k1n = Table.SelectRows(source, //оставляем строки с 1к, 1н
        each ([классификатор_key] = "1к") or ([классификатор_key] = "1н")
    ),
    group_data = Table.Group(
        filter_1k1n, 
        {
            "дата", 
            "схема.год",
            "схема.месяц год",
            "проект", 
            "подпроект", 
            "проект_key", 
            "схема.проект", 
            "схема.подпроект", 
            "организация", 
            "организация_key", 
            "схема.организация", 
            "классификатор_key", 
            "имя файла"
        }, 
        {
            {"часы", each List.Sum([часы]), type nullable number}, 
            {"стоимость руб", each List.Sum([стоимость руб]), type nullable number}}
    ),
    values_to_rec = Table.AddColumn(group_data, "Value", each [часы = [часы], #"стоимость руб" = [стоимость руб]]),
    remove_values = Table.RemoveColumns(values_to_rec,{"часы", "стоимость руб"}),
    pivot = Table.Pivot(remove_values, List.Distinct(remove_values[классификатор_key]), "классификатор_key", "Value"),
    expand_1k = Table.ExpandRecordColumn(pivot, "1к", {"часы", "стоимость руб"}, {"1к.часы", "1к.стоимость руб"}),
    expand_1n = Table.ExpandRecordColumn(expand_1k, "1н", {"часы", "стоимость руб"}, {"1н.часы", "1н.стоимость руб"})
in
    expand_1n