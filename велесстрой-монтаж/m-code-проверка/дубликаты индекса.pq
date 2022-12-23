let
    group_table = //группируем таблицу по ключу для получения дубликтов ключа
        Table.Group(
             #"контракт", 
            {"имя файла", "журнал номер", "индекс"}, 
            {
                {"кол-во дубликатов", Table.RowCount, type number}
            }
        ),
    filter_dup = Table.SelectRows(group_table, each [#"кол-во дубликатов"] > 1) //оставляем дубликаты индекса
in
    filter_dup