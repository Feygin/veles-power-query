/* 
    время обновления модели
 */
let
    today_date = DateTime.Date(DateTime.LocalNow()) & DateTime.Time(DateTime.LocalNow()), //сегодняшняя дата и время
    create_table = #table(type table [#"дата время" = datetime], {{today_date}}) //создаем таблицы с датой и временем
in
create_table