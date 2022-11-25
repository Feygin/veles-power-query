let
    source = #"_combined",
    replace_errors = fnReplaceAllErrors(source),

    //присоединяем таблицы к схеме
    //формируем ключи
    dup_project = Table.DuplicateColumn(replace_errors, "проект", "проект_dup"),
    dup_subproject = Table.DuplicateColumn(dup_project, "подпроект", "подпроект_dup"),
    dup_subcontractor = Table.DuplicateColumn(dup_subproject, "организация", "организация_key"),
    dup_classificator = Table.DuplicateColumn(dup_subcontractor, "классификатор", "классификатор_key"),
    dup_tipovie = Table.DuplicateColumn(dup_classificator, "типовые", "типовые_key"),
    clean_dups = Table.TransformColumns(
        dup_tipovie,
        {
            {"проект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"подпроект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"организация_key", each Text.Trim(Text.Clean(Text.Lower(_))), type text},
            {"типовые_key", each Text.Trim(Text.Clean(Text.Lower(_))), type text},
            {"классификатор_key", each Text.Replace(Text.Clean(Text.Lower(_)), " ", ""), type text}
    }),
    create_project_key = Table.CombineColumns(clean_dups,{"проект_dup", "подпроект_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"проект_key"),
    //join схема tables
    join_calendar = Table.NestedJoin(create_project_key, {"дата"}, #"календарь", {"дата"}, "дата_joined", JoinKind.LeftOuter),
    expand_calendar = Table.ExpandTableColumn(join_calendar, "дата_joined", {"год", "месяц год"}, {"схема.год", "схема.месяц год"}),
    join_project = Table.NestedJoin(expand_calendar, {"проект_key"}, #"проект", {"проект_key"}, "проект_joined", JoinKind.LeftOuter),
    expand_project = Table.ExpandTableColumn(join_project, "проект_joined", {"проект", "подпроект"}, {"схема.проект", "схема.подпроект"}),
    join_subcontractor = Table.NestedJoin(expand_project, {"организация_key"}, #"организация", {"организация_key"}, "организация_joined", JoinKind.LeftOuter),
    expand_subconractor = Table.ExpandTableColumn(join_subcontractor, "организация_joined", {"организация"}, {"схема.организация"}),
    join_classificator = Table.NestedJoin(expand_subconractor, {"классификатор_key"}, #"классификатор", {"классификатор_key"}, "классификатор_joined", JoinKind.LeftOuter),
    expand_classificator = Table.ExpandTableColumn(join_classificator, "классификатор_joined", {"классификатор с описанием"}, {"схема.классификатор с описанием"}),
    join_tipovie = Table.NestedJoin(expand_classificator, {"типовые_key"}, #"типовые", {"типовые_key"}, "типовые_joined", JoinKind.LeftOuter),
    expand_tipovie = Table.ExpandTableColumn(
        join_tipovie, 
        "типовые_joined", 
        {
            "типовые наименование",
            "типовые ур0 наименование",
            "типовые ур1 наименование", 
            "типовые ур2 наименование"
        }, 
        {
            "схема.типовые наименование",
            "схема.типовые ур0 наименование", 
            "схема.типовые ур1 наименование", 
            "схема.типовые ур2 наименование"
        }
    ),
    select_final_cols = Table.SelectColumns(
        expand_tipovie,
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
            "классификатор",
            "классификатор_key",
            "схема.классификатор с описанием",
            "работа описание",
            "работа группа",
            "типовые",
            "типовые_key",
            "схема.типовые наименование",
            "схема.типовые ур0 наименование", 
            "схема.типовые ур1 наименование", 
            "схема.типовые ур2 наименование",
            "часы",
            "стоимость руб",
            "имя файла"
        }
    )
in
    select_final_cols
