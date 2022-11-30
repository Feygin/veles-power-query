let
    source = #"_типовые_иcточник", 

    //добавляем столбцы для формирования иерархии типовых позиций по уровням
    select_initial_columns = Table.SelectColumns(
        source,
        {
            "типовые наименование",
            "ед изм",
            "типовые",
            "типовые_key",
            "типовые вед поз",
            "типовые уровень",
            "типовые вид работ",
            "добавлено гувр"
        }
    ),
    trim_description = Table.TransformColumns(select_initial_columns,{{"типовые наименование", Text.Trim, type text}}),

    //функция для объединения значений в столбцах через "-" 
    fnCombineCols = 
        (first_col, second_col)=>
            (row)=>
                let
                    first = Record.Field(row, first_col),
                    second = Record.Field(row, second_col),
                    combine = Text.Combine({first, second},  " - "),
                    result = if first <> null and second <> null then combine else null
                in
                    result,
    //наименование типовых позиций без ед изм и кода
    lvl0 = Table.AddColumn(trim_description, "типовые ур0 наименование", each if [типовые уровень] = 0 then [типовые наименование] else null),
    lvl1 = Table.AddColumn(lvl0, "типовые ур1 наименование", each if [типовые уровень] = 1 then [типовые наименование] else null),
    lvl2 = Table.AddColumn(lvl1, "типовые ур2 наименование", each if [типовые уровень] = 2 then [типовые наименование] else null),
    lvl3 = Table.AddColumn(lvl2, "типовые ур3 наименование", each if [типовые уровень] = 3 then [типовые наименование] else null),
    lvl4 = Table.AddColumn(lvl3, "типовые ур4 наименование", each if [типовые уровень] = 4 then [типовые наименование] else null),
    //наименование типовых позиций с ед изм
    lvl0_with_unit = Table.AddColumn(lvl4, "типовые ур0 наименование с ед изм", fnCombineCols("типовые ур0 наименование", "ед изм")), 
    lvl1_with_unit = Table.AddColumn(lvl0_with_unit, "типовые ур1 наименование с ед изм", fnCombineCols("типовые ур1 наименование", "ед изм")),
    lvl2_with_unit = Table.AddColumn(lvl1_with_unit, "типовые ур2 наименование с ед изм", fnCombineCols("типовые ур2 наименование", "ед изм")),
    lvl3_with_unit = Table.AddColumn(lvl2_with_unit, "типовые ур3 наименование с ед изм", fnCombineCols("типовые ур3 наименование", "ед изм")),
    lvl4_with_unit = Table.AddColumn(lvl3_with_unit, "типовые ур4 наименование с ед изм", fnCombineCols("типовые ур4 наименование", "ед изм")),
    //наименование типовых позиций с ед изм и кодом
    lvl0_with_unit_and_key = Table.AddColumn(lvl4_with_unit, "типовые ур0 наименование с ед изм и кодом", fnCombineCols("типовые", "типовые ур0 наименование с ед изм")),
    lvl1_with_unit_and_key = Table.AddColumn(lvl0_with_unit_and_key, "типовые ур1 наименование с ед изм и кодом", fnCombineCols("типовые", "типовые ур1 наименование с ед изм")), 
    lvl2_with_unit_and_key = Table.AddColumn(lvl1_with_unit_and_key, "типовые ур2 наименование с ед изм и кодом", fnCombineCols("типовые", "типовые ур2 наименование с ед изм")),
    lvl3_with_unit_and_key = Table.AddColumn(lvl2_with_unit_and_key, "типовые ур3 наименование с ед изм и кодом", fnCombineCols("типовые", "типовые ур3 наименование с ед изм")),
    lvl4_with_unit_and_key = Table.AddColumn(lvl3_with_unit_and_key, "типовые ур4 наименование с ед изм и кодом", fnCombineCols("типовые", "типовые ур4 наименование с ед изм")),
    fill_down_groups = Table.FillDown(
        lvl4_with_unit_and_key,
        {
            "типовые ур0 наименование", 
            "типовые ур1 наименование", 
            "типовые ур2 наименование", 
            "типовые ур3 наименование", 
            "типовые ур4 наименование", 
            "типовые ур0 наименование с ед изм", 
            "типовые ур1 наименование с ед изм", 
            "типовые ур2 наименование с ед изм", 
            "типовые ур3 наименование с ед изм", 
            "типовые ур4 наименование с ед изм", 
            "типовые ур0 наименование с ед изм и кодом", 
            "типовые ур1 наименование с ед изм и кодом", 
            "типовые ур2 наименование с ед изм и кодом", 
            "типовые ур3 наименование с ед изм и кодом", 
            "типовые ур4 наименование с ед изм и кодом"
        }
    ),
    //путь типовых позиций в иерархии, используем метод аналогичный журналам вм
    fnGetHierarchy = (row)=>
        let
            HIERARCHY_COLUMN = "типовые уровень",
            KEY_COLUMN = "типовые_key",
            MAX_LEVEL = 4,

            hierarchy_level = Record.Field(row, HIERARCHY_COLUMN),
            key = Record.Field(row, KEY_COLUMN),
            nulls = List.Repeat({null}, hierarchy_level),
            stoppers = List.Repeat({""}, MAX_LEVEL - hierarchy_level),
            combine = nulls & {key} & stoppers,
            hierarchy_record = Record.FromList(combine, {"типовые ур0", "типовые ур1", "типовые ур2", "типовые ур3", "типовые ур4"})
        in
            hierarchy_record,
    add_hierarchy = Table.AddColumn(fill_down_groups, "_hierarchy", fnGetHierarchy),
    expand_hierarchy = Table.ExpandRecordColumn(add_hierarchy, "_hierarchy", {"типовые ур0", "типовые ур1", "типовые ур2", "типовые ур3", "типовые ур4"}),
    fill_down_hierarchy = Table.FillDown(expand_hierarchy, {"типовые ур0", "типовые ур1", "типовые ур2", "типовые ур3", "типовые ур4"}),
    merge_keys = Table.CombineColumns(
        fill_down_hierarchy,
        {"типовые ур0", "типовые ур1", "типовые ур2", "типовые ур3", "типовые ур4"},
        Combiner.CombineTextByDelimiter("|", QuoteStyle.None),
        "типовые путь"
    ),
    trim_keys = Table.TransformColumns(merge_keys,{{"типовые путь", each Text.Trim(_, {"|"}), type text}}),

    //описания типовых позиции на уровне ключа
    key_description_with_unit = Table.AddColumn(trim_keys, "типовые наименование с ед изм", fnCombineCols("типовые наименование", "ед изм")),
    key_description_with_unit_and_key = Table.AddColumn(key_description_with_unit, "типовые наименование с ед изм и кодом", fnCombineCols("типовые", "типовые наименование с ед изм")),
    //глубина уровня для DAX
    lvl_depth = Table.AddColumn(key_description_with_unit_and_key, "типовые ур глубина", each [типовые уровень] + 1),
    select_columns = Table.SelectColumns(
        lvl_depth,
        {
            "типовые",
            "ед изм",
            "типовые_key",
            "типовые путь",
            "типовые вид работ",
            "добавлено гувр",
            "типовые наименование",
            "типовые наименование с ед изм",
            "типовые наименование с ед изм и кодом",
            "типовые вед поз",
            "типовые уровень",
            "типовые ур глубина",
            "типовые ур0 наименование",
            "типовые ур1 наименование",
            "типовые ур2 наименование",
            "типовые ур3 наименование",
            "типовые ур4 наименование",
            "типовые ур0 наименование с ед изм",
            "типовые ур1 наименование с ед изм",
            "типовые ур2 наименование с ед изм",
            "типовые ур3 наименование с ед изм",
            "типовые ур4 наименование с ед изм",
            "типовые ур0 наименование с ед изм и кодом",
            "типовые ур1 наименование с ед изм и кодом",
            "типовые ур2 наименование с ед изм и кодом",
            "типовые ур3 наименование с ед изм и кодом",
            "типовые ур4 наименование с ед изм и кодом"
        }
    )
in
    select_columns