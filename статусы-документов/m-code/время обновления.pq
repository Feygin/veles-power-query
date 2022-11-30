let
    today_date = DateTime.Date(DateTime.LocalNow()) & DateTime.Time(DateTime.LocalNow()),
    create_table = #table(type table [#"дата время" = datetime], {{today_date}})
in
create_table