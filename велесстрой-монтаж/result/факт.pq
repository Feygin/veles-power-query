let
    source = #"_факт_источник",
    //убираем отмеченные "лишние строки"
    filter_rows_to_include = Table.SelectRows(source, each ([индекс включить] <> null) and ([индекс включить] <> "")),
    //преобразовываем тип данных
    change_dtype = Table.TransformColumnTypes(
        filter_rows_to_include,
        {
            {"индекс", type text}, 
            {"индекс иерархия", type text},
            {"дата", type date}, 
            {"норма", type number}, 
            {"объем факт", type number}, 
            {"часы факт", type number}, 
            {"часы техника факт", type number}, 
            {"журнал номер", type text}
        }
    ),
    //извлекаем начало месяца
    extract_first_day_of_month = 
        if #"PrExtractFirstDayOfMonth" = "да" then
            Table.TransformColumns(change_dtype,{{"дата", Date.StartOfMonth, type date}})
        else
            change_dtype,
    //присоединяем зимний к-т и кодировку
    join_winter_rate = Table.NestedJoin(extract_first_day_of_month, {"дата"}, #"зимний_коэф", {"дата"}, "зимний_joined", JoinKind.LeftOuter),
    expand_winter_rate = Table.ExpandTableColumn(join_winter_rate, "зимний_joined", {"зимний коэф"}),
    join_codes = Table.NestedJoin(expand_winter_rate, {"журнал номер", "индекс"}, #"кодировка", {"журнал номер", "индекс"}, "кодировка_joined", JoinKind.LeftOuter),
    expand_codes = Table.ExpandTableColumn(join_codes, "кодировка_joined", {"типовые", "типовые вед поз", "сборник нормативов", "сборник нормативов вед поз"}),
    //вычисляем значение зимнего коэффициента
    add_project_hours = 
        let
            add_project_hours = Table.AddColumn(expand_codes, "нормочасы факт", each Number.Round([объем факт] * [норма],2), type number),
            add_project_hours_winter = Table.AddColumn(
                add_project_hours,
                "нормочасы зимний факт",
                each Number.Round([объем факт] * [норма]  * (if [зимний коэф условие] <> null then [зимний коэф] else 1),2),
                type number
            )  
        in
            add_project_hours_winter,
    //присоединяем схему
    dup_project = Table.DuplicateColumn(add_project_hours, "проект", "проект_dup"),
    dup_subproject = Table.DuplicateColumn(dup_project, "подпроект", "подпроект_dup"),
    dup_subcontractor = Table.DuplicateColumn(dup_subproject, "организация", "организация_key"),
    clean_dups = Table.TransformColumns(
        dup_subcontractor,
        {
            {"проект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"подпроект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"организация_key", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
    }),
    norm_keys = 
        let
            norm_project = fnReplaceMultipleValues(clean_dups, [columns = {"проект_dup"}, replacement = #"нормализация_проект"]),
            norm_subproject = fnReplaceMultipleValues(norm_project, [columns = {"подпроект_dup"}, replacement = #"нормализация_подпроект"]),
            norm_subcontractor = fnReplaceMultipleValues(norm_subproject, [columns = {"организация_key"}, replacement = #"нормализация_организация"])
        in
            norm_subcontractor,
    create_project_key = Table.CombineColumns(norm_keys,{"проект_dup", "подпроект_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"проект_key"),
    //join схема tables
    join_calendar = Table.NestedJoin(create_project_key, {"дата"}, #"календарь", {"дата"}, "дата_joined", JoinKind.LeftOuter),
    expand_calendar = Table.ExpandTableColumn(join_calendar, "дата_joined", {"месяц год"}, {"схема.месяц год"}),
    join_project = Table.NestedJoin(expand_calendar, {"проект_key"}, проект, {"проект_key"}, "проект_joined", JoinKind.LeftOuter),
    expand_project = Table.ExpandTableColumn(join_project, "проект_joined", {"проект", "подпроект"}, {"схема.проект", "схема.подпроект"}),
    join_subcontractor = Table.NestedJoin(expand_project, {"организация_key"}, организация, {"организация_key"}, "организация_joined", JoinKind.LeftOuter),
    expand_subconractor = Table.ExpandTableColumn(join_subcontractor, "организация_joined", {"организация"}, {"схема.организация"}),
    join_tipovie = Table.NestedJoin(expand_subconractor, {"типовые"}, #"типовые", {"типовые_key"}, "типовые_joined", JoinKind.LeftOuter),
    expand_tipovie = Table.ExpandTableColumn(
        join_tipovie, 
        "типовые_joined", 
        {
            "типовые наименование с ед изм и кодом",
            "типовые ур0 наименование с ед изм и кодом", 
            "типовые ур0 вед поз", 
            "типовые ур1 наименование с ед изм и кодом", 
            "типовые ур1 вед поз", 
            "типовые ур2 наименование с ед изм и кодом", 
            "типовые ур2 вед поз", 
            "типовые ур3 наименование с ед изм и кодом", 
            "типовые ур3 вед поз", 
            "типовые ур4 наименование с ед изм и кодом", 
            "типовые ур4 вед поз"
        }, 
        {
            "схема.типовые наименование с ед изм и кодом",
            "схема.типовые ур0 наименование с ед изм и кодом", 
            "схема.типовые ур0 вед поз", 
            "схема.типовые ур1 наименование с ед изм и кодом", 
            "схема.типовые ур1 вед поз", 
            "схема.типовые ур2 наименование с ед изм и кодом", 
            "схема.типовые ур2 вед поз", 
            "схема.типовые ур3 наименование с ед изм и кодом", 
            "схема.типовые ур3 вед поз", 
            "схема.типовые ур4 наименование с ед изм и кодом", 
            "схема.типовые ур4 вед поз"
        }
    ),
    add_refresh_date = fnAddRefreshDateTime(expand_tipovie, [column = "время обновления база"]),
    reorder_cols = Table.ReorderColumns(add_refresh_date, #"столбцы_факт_фин", MissingField.Ignore)
in
    reorder_cols