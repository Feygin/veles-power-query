let
    source = #"_ключевые_иcточник",  //ссылка на предыдущий шаг
    select_initial_columns = Table.SelectColumns( //оставляем требуемые столбцы
        source,
        {
            "ключевые наименование",
            "ед изм",
            "ключевые наименование с ед изм",
            "ключевые уровень",
            "ключевые вед поз",
            "типовые_key",
            "типовые вед поз"
        }
    ),
    trim_description = Table.TransformColumns( //убираем ведущие пробелы в столбцах с иерархией 
        select_initial_columns,{ //которые использовались для форматирования 
            {"ключевые наименование", Text.Trim, type text},
            {"ключевые наименование с ед изм", Text.Trim, type text}
        }
    ),

    //раскрываем иерархию в новые столбцы по ее номеру
    //если номер совпадает, то добавляем наименование, если нет, то оставляем пустым
    //далее заполним пустые значения наименованием иерархии сверху - вниз
    lvl0 = Table.AddColumn(trim_description, "ключевые ур0 наименование", each if [ключевые уровень] = 0 then [ключевые наименование] else null), //добавляем столбцы с иерархией
    lvl1 = Table.AddColumn(lvl0, "ключевые ур1 наименование", each if [ключевые уровень] = 1 then [ключевые наименование] else null),
    lvl0_with_unit = Table.AddColumn(lvl1, "ключевые ур0 наименование с ед изм", each if [ключевые уровень] = 0 then [ключевые наименование с ед изм] else null),
    lvl1_with_unit = Table.AddColumn(lvl0_with_unit, "ключевые ур1 наименование с ед изм", each if [ключевые уровень] = 1 then [ключевые наименование с ед изм] else null),

     fill_down_groups = Table.FillDown( //заполняем столбцы с иерархией
        lvl1_with_unit, //первый уровень является последним, для него заполнение не требуется
        {
            "ключевые ур0 наименование", 
            "ключевые ур0 наименование с ед изм"
        }
    ),

    //создаем столбец с путем иерархии
    dup_lvl0_with_unit = Table.DuplicateColumn(fill_down_groups, "ключевые ур0 наименование с ед изм", "ключевые ур0 наименование с ед изм_copy"), //дублируем столбцы с ключом
    dup_lvl1_with_unit = Table.DuplicateColumn(dup_lvl0_with_unit, "ключевые ур1 наименование с ед изм", "ключевые ур1 наименование с ед изм_copy"), //объединяем столбцы
    make_path = Table.CombineColumns(
        dup_lvl1_with_unit,
        {
            "ключевые ур0 наименование с ед изм_copy", 
            "ключевые ур1 наименование с ед изм_copy"
        },
        Combiner.CombineTextByDelimiter("|", QuoteStyle.None),
        "ключевые путь"
    ),
    trim_keys = Table.TransformColumns(make_path,{{"ключевые путь", each Text.Trim(_, {"|"}), type text}}) //убираем лишние символы
in
    trim_keys