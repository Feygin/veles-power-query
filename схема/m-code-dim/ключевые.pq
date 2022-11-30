let
    source = #"_ключевые_объединение",
    duplicate_name_col = Table.DuplicateColumn(source, "ключевые наименование", "ключевые наименование_dup"),
    duplicate_unit_col = Table.DuplicateColumn(duplicate_name_col, "ед изм", "ед изм_dup"),
    clean_keys = fnCleanData(duplicate_unit_col, [columns =  {"ключевые наименование_dup", "ед изм_dup"}]),
    combine_key = Table.CombineColumns(clean_keys,  {"ключевые наименование_dup", "ед изм_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"ключевые_key"),
    check_pk = fnCheckPrimaryKey(combine_key, [column = "ключевые_key", file_name = "справочник google", table_name = "ключевые"]),
    add_sort = fnAddSort(check_pk, [columns = {"ключевые ур0 наименование", "ключевые ур1 наименование", "ключевые ур0 наименование с ед изм", "ключевые ур1 наименование с ед изм"}]),
    add_slicers = 
        let
            add_lvl0_unit_slicer = Table.AddColumn(add_sort, "ключевые ур0 наименование срез", each [ключевые ур0 наименование]),
            add_lvl1_unit_slicer = Table.AddColumn(add_lvl0_unit_slicer, "ключевые ур1 наименование срез", each [ключевые ур1 наименование]),
            add_lvl0_unit_with_descr_slicer = Table.AddColumn(add_lvl1_unit_slicer, "ключевые ур0 наименование с ед изм срез", each [ключевые ур0 наименование с ед изм]),
            add_lvl1_unit_with_descr_slicer = Table.AddColumn(add_lvl0_unit_with_descr_slicer, "ключевые ур1 наименование с ед изм срез", each [ключевые ур1 наименование с ед изм])
        in
            add_lvl1_unit_with_descr_slicer,
    add_depth = Table.AddColumn(add_slicers, "ключевые уровень глубина", each [ключевые уровень] + 1),
    add_refresh_datetime = fnAddRefreshDateTime(add_depth, [column = "время обновления google"]),
    select_columns = Table.SelectColumns(
        add_refresh_datetime,
        {
            "ключевые_key",
            "ключевые наименование",
            "ед изм",
            "ключевые наименование с ед изм",
            "ключевые уровень",
            "ключевые уровень глубина",
            "ключевые путь",
            "ключевые вед поз",
            "типовые_key",
            "типовые вед поз",
            "ключевые ур0 наименование",
            "ключевые ур0 наименование с ед изм",
            "ключевые ур0 вед поз",
            "ключевые ур1 наименование",
            "ключевые ур1 наименование с ед изм",
            "ключевые ур1 вед поз",
            "ключевые ур0 наименование_sort",
            "ключевые ур1 наименование_sort",
            "ключевые ур0 наименование с ед изм_sort",
            "ключевые ур1 наименование с ед изм_sort",
            "ключевые ур0 наименование срез",
            "ключевые ур1 наименование срез",
            "ключевые ур0 наименование с ед изм срез",
            "ключевые ур1 наименование с ед изм срез",
            "время обновления google"
        }
    )
in
    select_columns