/* 
    извлекаем и трансформируем листы с журналами
 */
let
    folder_content = fnGetFolderContent(#"журналы_путь", [exclude_subfolders = true]), //извлекаем содержимое файлов в папке
    rename_attributes = Table.RenameColumns(folder_content, {{"Name", "имя файла"}, {"Item", "лист"}}), //переименовываем столбцы с метаданными
    norm_names = Table.TransformColumns( //нормализуем значения метаданных
        rename_attributes,
        {
            {"имя файла", each Text.Trim(Text.Lower(_))},
            {"лист", each Text.Trim(Text.Lower(_))}
        }
    ),
    select_valid_extension = Table.SelectRows( //оставляем файлы с расширением: xlsx, xlsm
        norm_names,
        each Text.EndsWith([имя файла], "xlsx") or Text.EndsWith([имя файла], "xlsm")
    ),
    select_sheets = Table.SelectRows(  //оставляем заданные пользователем листы
        select_valid_extension,
        each List.Contains({#"PrSheetName"}, [лист])
            and [Kind] = "Sheet"
    ),
    select_columns = Table.SelectColumns(select_sheets, {"имя файла", "лист", "Data"}), //оставляем данные и метаданные
  
    extract_header = Table.AddColumn(select_columns, "ExtractHeader",  each fnExtractHeader([Data])), //преобразовываем многострочную шапку

    fnAddFileName = //функция для добавления аттрибута с именем файла к таблице
        (source, filename)=> Table.AddColumn(source, "имя файла", each filename),
    add_filename = Table.AddColumn(extract_header, "AddFileName",  each fnAddFileName([ExtractHeader], [имя файла])), //добавляем имя файла к таблицам

    unfold_hierarchy = Table.AddColumn( //раскрываем иерархию
        add_filename, 
        "UnfoldHierarchy",  
        each fnUnfoldHierarchy([AddFileName], 10, "контракт^индекс иерархия^^", "контракт^" & #"PrLvlDescriptionName" & "^^")
    ),

    fnFilterIndex = //функция для фильтрации строк таблицы по полю индекс
        (source, index_column)=>
            let
                // [
                    replace_errors = fnReplaceAllErrors(source), //заменяем все ошибки в таблице
                    filter = Table.SelectRows( //так мы предотвратим ошибку при фильтрации таблицы если в поле индекс есть ошибки 
                        replace_errors, 
                        each (Record.Field(_, index_column) <> null) and //фильтруем строки с незаполненным индексом
                                (Record.Field(_, index_column) <> "")
                    )
                // ]
            in
                filter,
    filter_index = Table.AddColumn(unfold_hierarchy, "FilterIndex",  each fnFilterIndex([UnfoldHierarchy], "контракт^индекс^^")), //исключаем непроиндексированные строки

    normalize_header = Table.AddColumn(unfold_hierarchy, "NormalizedColumns",  each fnNormalizeHeader([UnfoldHierarchy])),
    select_contract_part = Table.AddColumn(normalize_header, "SelectContract",  each fnSelectContractColumns([UnfoldHierarchy], [NormalizedColumns])),
    select_fact_part = Table.AddColumn(select_contract_part, "SelectFact",  each fnSelectFactColumns([UnfoldHierarchy], [NormalizedColumns])),
    unpivot_fact = Table.AddColumn(select_fact_part, "FactUnpivot",  each fnUnpivot([SelectFact])),
    check_errors = Table.AddColumn(
        unpivot_fact, 
        "статус извлечения", 
        each if (try [ExtractHeader])[HasError] then "Ошибка при извлечении заголовка: "  & fnExtractErrDescription((try [ExtractHeader])[Error])
             else if (try [UnfoldHierarchy])[HasError] then "Ошибка при извлечении уровней иерархии: "  & fnExtractErrDescription((try [UnfoldHierarchy])[Error])
             else if (try [FactUnpivot])[HasError] then "Ошибка при трансформации блока с периодами: "  & fnExtractErrDescription((try [FactUnpivot])[Error])
             else "Извлечено"
    )
in
    check_errors