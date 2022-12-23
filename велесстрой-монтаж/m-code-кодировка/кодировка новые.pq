/* 
    получаем таблицу с новыми позициями для кодировки
 */
let
    select_contract_columns = Table.SelectColumns( //выбираем контрактные столбцы
        #"контракт",
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
            "норма",
            "объем контракт",
            "объем накопительно",
            "часы накопительно"
        }
    ),
    contract_remove_err = fnReplaceAllErrors(select_contract_columns), //удаляем ошибки
    select_rows_with_data = Table.SelectRows( //оставляем строки с отличными от 0, null накопительными часами или объемами
        contract_remove_err,
        each ([объем накопительно] <> 0 and [объем накопительно] <> null)
                or ([часы накопительно] <> 0 and [часы накопительно] <> null)
    ),
    get_new_positions = //получаем позиции которые есть в контракте, но отсутствуют в кодировке
        Table.NestedJoin(
            select_rows_with_data, {"журнал номер", "индекс"},
            #"кодировка",{"журнал номер", "индекс"},
            "new_positions_joined",
            JoinKind.LeftAnti
        ),
    remove_temp_column = Table.RemoveColumns(get_new_positions, {"new_positions_joined"}), //удаляем временный столбец с join
    add_tipovie_cols = Table.AddColumn(remove_temp_column, "типовые", each null), //добавляем аттрибуты типовые, типовые вед поз 
    add_tipovie_leadin_cols = Table.AddColumn(add_tipovie_cols, "типовые вед поз", each null) //для соответствия с таблицей кодировка
in
	add_tipovie_leadin_cols