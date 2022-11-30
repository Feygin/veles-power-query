let
    contract_remove_err = fnReplaceAllErrors(#"контракт"),
    get_new_positions = //получаем позиции которые есть в базе, но отсутствуют в кодировке
        Table.NestedJoin(
            contract_remove_err, {"журнал номер", "индекс"},
            #"кодировка",{"журнал номер", "индекс"},
            "new_positions_joined",
            JoinKind.LeftAnti
        ),
    filter_with_data = 
        Table.NestedJoin(
            get_new_positions, {"журнал номер", "индекс"},
            #"факт",{"журнал номер", "индекс"},
            "with_fact_joined",
            JoinKind.Inner
        ),
    select_cols = Table.SelectColumns(
        filter_with_data, 
        {
            "имя файла",
            "журнал номер",
            "индекс",
            "индекс иерархия",
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
            "объем контракт",
            "норма",
            "типовые",
            "типовые вед поз",
            "сборник нормативов",
            "сборник нормативов вед поз"
        },
        MissingField.UseNull
    )
in
	select_cols