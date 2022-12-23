/* 
    создаем таблицу контракт
 */
let
    //извлекаем таблицу
    source = Excel.Workbook(File.Contents(#"база_путь"), null, true), //извлекаем содержимое базы журналов
    data = source{[Item="контракт",Kind="Table"]}[Data], //извлекаем таблицу контракт
    check_any_data = //проверяем наличие таблицы контракт в файле
        if (try data)[HasError] = true then //если таблица отсутствует
            error Error.Record("Не удается найти таблицу контракт в " & #"база_путь") //выводим пользовательскую ошибку
        else
            data,
    select_cols = Table.SelectColumns( //отбираем аттрибуты таблицы
        check_any_data,
        {
            "индекс",
            "индекс иерархия",
            "индекс включить",
            "проект",
            "подпроект",
            "организация",
            "ркц поз",
            "ркц ур1",
            "ркц ур2",
            "ркц ур3",
            "ркц ур4",
            "ркц ур5",
            "ркц ур6",
            "ркц ур7",
            "ркц ур8",
            "ркц ур9",
            "ркц ур10",
            "ркц описание",
            "ед изм",
            "норма",
            "объем контракт",
            "объем накопительно",
            "часы накопительно",
            "часы техника накопительно",
            "имя файла",
            "время обновления журнала"
        },
        MissingField.UseNull //если аттрибут отсутствует добавлем аттрибут со значениями null
    ),
    //извлекаем метаданные из имени журнала
    extract_file_attr = Table.AddColumn(select_cols, "имя файла аттрибуты", each fnParseLogName([имя файла])), //извлекаем метаданные из имени журнала
    expand_file_attr = Table.ExpandRecordColumn( //раскрываем запись с извлеченными метаданными в столбцы таблицы
        extract_file_attr, 
        "имя файла аттрибуты", 
        {"is_valid_template", "log_id", "project_name", "area", "subcontractor"}, 
        {"журнал.проверка имени", "журнал номер", "журнал.проект", "журнал.подпроект", "журнал.организация"}
    ),
    coalesce_attr = //coalesce извлеченных метаданных с существующими аттрибутами таблицы
        let
            coalesce_project = Table.ReplaceValue(expand_file_attr, each [проект], each if ([журнал.проверка имени] = true) and ([проект] = null) then [журнал.проект] else [проект], Replacer.ReplaceValue, {"проект"}), //coalesce проект
            coalesce_subproject = Table.ReplaceValue(coalesce_project, each [подпроект], each if ([журнал.проверка имени] = true) and ([подпроект] = null) then [журнал.подпроект] else [подпроект], Replacer.ReplaceValue, {"подпроект"}), //coalesce подпроект
            coalesce_subcontracor = Table.ReplaceValue(coalesce_subproject, each [организация], each if ([журнал.проверка имени] = true) and ([организация] = null) then [журнал.организация] else [организация], Replacer.ReplaceValue, {"организация"}), //coalesce организация
            remove_expaned_cols = Table.RemoveColumns(coalesce_subcontracor,{"журнал.проверка имени", "журнал.проект", "журнал.подпроект", "журнал.организация"}) //удаляем извлеченные столбцы
        in
            remove_expaned_cols,
    //удаляем лишние строки
    filter_rows_to_include = Table.SelectRows(coalesce_attr, each ([индекс включить] <> null) and ([индекс включить] <> "")), //убираем строки не отмеченные в аттрибуте "индекс включить"
    replace_dots_in_nums = fnReplaceSymbols( //заменяем "." на "," в числовых столбцах, чтобы при преобразовании
        filter_rows_to_include, //типа данных не появились ошибки
        [
            columns = {
                "норма", 
                "объем контракт", 
                "объем накопительно", 
                "часы накопительно",
                "часы техника накопительно"
            }, 
            replacement = {{".", ","}}
        ] 
    ),
    change_dtype = Table.TransformColumnTypes( //преобразовываем тип данных
        replace_dots_in_nums,
            {
                {"журнал номер", type text},
                {"индекс", type text}, 
                {"индекс иерархия", type text},
                {"индекс включить", type text},
                {"проект", type text},
                {"подпроект", type text},
                {"организация", type text},
                {"ркц поз", type text},
                {"ркц ур1", type text},
                {"ркц ур2", type text},
                {"ркц ур3", type text},
                {"ркц ур4", type text},
                {"ркц ур5", type text},
                {"ркц ур6", type text},
                {"ркц ур7", type text},
                {"ркц ур8", type text},
                {"ркц ур9", type text},
                {"ркц ур10", type text},
                {"ркц описание", type text},
                {"ед изм", type text},
                {"норма", type number}, 
                {"объем контракт", type number}, 
                {"объем накопительно", type number}, 
                {"часы накопительно", type number}, 
                {"часы техника накопительно", type number},
                {"имя файла", type text},
                {"время обновления журнала", type date}
            }
    ),
    //нормализуем ключи и обогащаем данными из справочников
    dup_keys = //дублируем аттрибуты с ключами
        let
            dup_project = Table.DuplicateColumn(change_dtype, "проект", "проект_dup"),
            dup_subproject = Table.DuplicateColumn(dup_project, "подпроект", "подпроект_dup"),
            dup_subcontractor = Table.DuplicateColumn(dup_subproject, "организация", "организация_key")
        in
            dup_subcontractor,
    clean_keys = Table.TransformColumns( //нормализуем ключи
        dup_keys,
        {
            {"журнал номер", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"индекс", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"проект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"подпроект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"организация_key", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
        }
    ),
    norm_keys = //заменяем значения проекта, подпроекта, организации согласно пользовательскому списку
        let
            norm_project = fnReplaceMultipleValues(clean_keys, [columns = {"проект_dup"}, replacement = #"нормализация_проект"]), //заменяем проект
            norm_subproject = fnReplaceMultipleValues(norm_project, [columns = {"подпроект_dup"}, replacement = #"нормализация_подпроект"]), //заменяем подпроект
            norm_subcontractor = fnReplaceMultipleValues(norm_subproject, [columns = {"организация_key"}, replacement = #"нормализация_организация"]) //заменяем организацию
        in
            norm_subcontractor,

    //присоединяем кодировку
    join_codes = Table.NestedJoin(norm_keys, {"журнал номер", "индекс"}, #"кодировка", {"журнал номер", "индекс"}, "кодировка_joined", JoinKind.LeftOuter), 
    expand_codes = Table.ExpandTableColumn(join_codes, "кодировка_joined", {"типовые", "типовые вед поз"}),
    //присоединяем схему
    create_project_key = Table.CombineColumns(expand_codes,{"проект_dup", "подпроект_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"проект_key"), //создаем ключ проекта
    join_project = Table.NestedJoin(create_project_key, {"проект_key"}, проект, {"проект_key"}, "проект_joined", JoinKind.LeftOuter), //присоединяем проект
    expand_project = Table.ExpandTableColumn(join_project, "проект_joined", {"проект", "подпроект"}, {"схема.проект", "схема.подпроект"}),
    join_subcontractor = Table.NestedJoin(expand_project, {"организация_key"}, организация, {"организация_key"}, "организация_joined", JoinKind.LeftOuter), //присоединяем организацию
    expand_subconractor = Table.ExpandTableColumn(join_subcontractor, "организация_joined", {"организация"}, {"схема.организация"}),
    join_tipovie = Table.NestedJoin(expand_subconractor, {"типовые"}, #"типовые", {"типовые_key"}, "типовые_joined", JoinKind.LeftOuter), //присоединяем типовые
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
    add_project_hours = //вычисляем нормочасы по контракту
        let
            add_project_hours = Table.AddColumn(expand_tipovie, "нормочасы контракт", each Number.Round([объем контракт] * [норма],2), type number)
        in
            add_project_hours,
    add_refresh_date = fnAddRefreshDateTime(add_project_hours, [column = "время обновления база"]), //добавляем аттрибут с временем обновления
    reorder_cols = Table.ReorderColumns( //задаем расположение столбцов
        add_refresh_date, 
        {
            "журнал номер",
            "индекс",
            "индекс иерархия",
            "индекс включить",
            "проект",
            "подпроект",
            "проект_key",
            "схема.проект",
            "схема.подпроект",
            "организация",
            "организация_key",
            "схема.организация",
            "ркц поз",
            "ркц ур1",
            "ркц ур2",
            "ркц ур3",
            "ркц ур4",
            "ркц ур5",
            "ркц ур6",
            "ркц ур7",
            "ркц ур8",
            "ркц ур9",
            "ркц ур10",
            "ркц описание",
            "ед изм",
            "типовые",
            "типовые вед поз",
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
            "схема.типовые ур4 вед поз",
            "норма",
            "объем контракт",
            "нормочасы контракт",
            "объем накопительно",
            "часы накопительно",
            "часы техника накопительно",
            "имя файла",
            "время обновления журнала",
            "время обновления база"
        }
    )
in
    reorder_cols