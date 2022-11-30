/* 
    Цель: добавление столбца с временем и датой обновления
 */
(
    source,
    _parameter as record
)=>
    let
        column = Record.FieldOrDefault(_parameter, "column", "время обновления"),

        current_datetime = DateTime.Date(DateTime.LocalNow()) & DateTime.Time(DateTime.LocalNow()),
        add_refresh_datetime = Table.AddColumn(source, column, each current_datetime, type datetime)
    in
        add_refresh_datetime