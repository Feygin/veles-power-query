let
    folder_content = fnGetFolderContent(#"log_path", [exclude_subfolders = true]),
    rename_attributes = Table.RenameColumns(folder_content, {{"Name", "имя файла"}, {"Item", "лист"}}),
    norm_names = Table.TransformColumns(
        rename_attributes,
        {
            {"имя файла", each Text.Trim(Text.Lower(_))},
            {"лист", each Text.Trim(Text.Lower(_))}
        }
    ),
    select_valid_extension = Table.SelectRows(
        norm_names,
        each Text.EndsWith([имя файла], "xlsx") or Text.EndsWith([имя файла], "xlsm")
    ),
    select_sheets = Table.SelectRows(
        select_valid_extension,
        each List.Contains({#"PrSheetName"}, [лист])
            and [Kind] = "Sheet"
    ),
    select_columns = Table.SelectColumns(select_sheets, {"имя файла", "лист", "Data"}),
  
    extract_header = Table.AddColumn(select_columns, "ExtractHeader",  each fnExtractHeader([Data])),

    fnAddFileName = 
        (source, filename)=> Table.AddColumn(source, "имя файла", each filename),
    add_filename = Table.AddColumn(extract_header, "AddFileName",  each fnAddFileName([ExtractHeader], [имя файла])),

    filter_index = Table.AddColumn(add_filename, "FilterIndex",  each fnFilterIndex([AddFileName], "контракт^индекс^^")),
    unfold_hierarchy = Table.AddColumn(filter_index, "UnfoldHierarchy",  each fnUnfoldHierarchy([FilterIndex], 10, "контракт^индекс иерархия^^", "контракт^" & #"PrLvlDescriptionName" & "^^")),
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