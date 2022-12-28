/* 
    формируем календарь
 */
let
    start = Excel.CurrentWorkbook(){[Name="календарь_параметр"]}[Content]{0}[период], //из таблицы с настройками получаем дату начала
    end = Excel.CurrentWorkbook(){[Name="календарь_параметр"]}[Content]{1}[период], //из таблицы с настройками получаем дату окончания
    list_with_dates = Table.FromList({Number.From(start)..Number.From(end)}, Splitter.SplitByNothing(), {"дата"}), //содаем список дат
    change_date_dtype = Table.TransformColumnTypes(list_with_dates,{{"дата", type date}}), //изменяем тип данных
    add_year_number = Table.AddColumn(change_date_dtype, "год_номер", each Date.Year([дата]), Int64.Type), //добавляем номер года
    add_year = Table.AddColumn( add_year_number, "год", each Date.ToText([дата], "yyyy"), Text.Type ), //добавляем название год
    add_quarter_number = Table.AddColumn( add_year, "квартал_номер", each Date.QuarterOfYear([дата]), Int64.Type ), //добавляем номер квартала
    add_quarter = Table.AddColumn( add_quarter_number, "квартал", each "кв." & Text.From([квартал_номер], "ru-RU"), Text.Type ), //добавляем название квартала
    add_quarter_year_number = Table.AddColumn( add_quarter, "квартал год_номер", each [год_номер]*4-1+[квартал_номер], Number.Type ), //добавляем номер квартала и года
    add_quarter_year = Table.AddColumn( add_quarter_year_number, "квартал год", each Text.Combine({[квартал], [год]}, " "), Text.Type ), //добавляем название квартала и года
    add_month_number = Table.AddColumn( add_quarter_year, "месяц_номер", each Date.Month([дата]), Int64.Type ), //добавляем номер месяца
    add_month = Table.AddColumn( add_month_number, "месяц", each Text.Start(Date.MonthName([дата],"ru-RU"),3), Text.Type ), //добавляем название месяца
    add_month_year_number = Table.AddColumn( add_month, "месяц год_номер", each [год_номер]*12-1+[месяц_номер], Number.Type ), //добавляем номер месяца и года
    add_month_year = Table.AddColumn( add_month_year_number, "месяц год", each Text.Combine({[месяц], [год]}, " "), Text.Type ), //добавляем наименование месяца и года
    add_week_number = Table.AddColumn( add_month_year, "неделя_номер", each Date.WeekOfYear([дата], Day.Monday), Int64.Type ), //добавляем номер недели
    add_week = Table.AddColumn( add_week_number, "неделя", each "нед." & Text.From([неделя_номер], "ru-RU"), Text.Type ), //добавляем наименование недели
    add_week_year_number = Table.AddColumn( add_week, "неделя год_номер", each Number.RoundDown( Duration.Days( [дата] - (#date(1900,12,30) + #duration(1,0,0,0)) ) / 7 ), Number.Type ), //добавляем номер недели и года
    add_week_year = Table.AddColumn( add_week_year_number, "неделя год", each Text.Combine({[неделя], [год]}, " - "), Text.Type ), //добавляем наименование недели и года
    add_day_of_month = Table.AddColumn( add_week_year, "день месяца", each Date.Day([дата]), Int64.Type ), //добавляем день месяца
    add_day_of_week_number = Table.AddColumn( add_day_of_month, "день недели_номер", each Date.DayOfWeek([дата], Day.Monday)+1, Int64.Type ), //добавляем номер дня недели
    add_day_of_week = Table.AddColumn( add_day_of_week_number, "день недели", each Date.ToText([дата],"ddd","ru-RU"), Text.Type ), //добавляем наименование дня недели
    add_decade_num = Table.AddColumn( add_day_of_week, "декада_номер", each if [день месяца] <= 10 then 1 else if [день месяца] <= 20 then 2 else 3, Number.Type ), //добавляем номер декады ОККС
    add_decade = Table.AddColumn( add_decade_num, "декада", each if [день месяца] <= 10 then "1 декада" else if [день месяца] <= 20 then "2 декада" else "3 декада", Text.Type ), //добавляем наименование декады ОККС
    add_decade_month_number = Table.AddColumn( add_decade, "декада месяц_номер", each ([месяц_номер] - 1) * 3 + [декада_номер], Number.Type ), //добавляем номер декады и месяца
    add_decade_month = Table.AddColumn( add_decade_month_number, "декада месяц", each [декада] & " " & [месяц], Text.Type ), //добавляем наименование декады и месяца
    add_decade_month_year_number = Table.AddColumn( add_decade_month, "декада месяц год_номер", each [год_номер] * 12 * 3 - 1 + [декада месяц_номер], Number.Type ), //добавляем номер декады месяца и года
    add_decade_month_year = Table.AddColumn( add_decade_month_year_number, "декада месяц год", each [декада] & " " & [месяц] & " " & [год], Text.Type ), //добавляем наименование декады месяца и года
    add_refresh_datetime = fnAddRefreshDateTime(add_decade_month_year, [column = "время обновления google"]) //добавляем время обновления
in
    add_refresh_datetime