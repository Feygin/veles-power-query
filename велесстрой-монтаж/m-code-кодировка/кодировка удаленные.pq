/* 
    получаем таблицу с удаленными из журнала позициями
 */
let
    loaded_logs = Table.FromColumns( //номера загруженных журналов
        {List.Distinct(#"кодировка"[журнал номер])},
        {"журнал номер"}
    ),
    filter_kodirovka_by_loaded_logs = 
        Table.NestedJoin( //фильтруем кодировку по текущим номерам журналов
            #"кодировка", "журнал номер", //чтобы избежать случайного удаления кодировки для журналов временно не загруженных в базу
            loaded_logs, "журнал номер",
            "контракт_cur_logs_joined",
            JoinKind.Inner
        ),
    get_removed_positions = //получаем позиции присутствующие в кодировке, но отсутствующие в базе
        Table.NestedJoin(
            filter_kodirovka_by_loaded_logs,{"журнал номер", "индекс"},
            #"контракт", {"журнал номер", "индекс"},
            "контракт_missing_codes_joined",
            JoinKind.LeftAnti
        ),
    select_cols = Table.SelectColumns(get_removed_positions, {"журнал номер", "индекс"}) //оставляем номер журнала и индекс
in
    select_cols