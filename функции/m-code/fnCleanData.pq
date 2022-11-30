/* 
    Цель: trim, lower, clean данных в заданных столбцах
 */
 (
    source as any, //таблица которую загружаем в модель,
    _parameter as record //параметры
)=>
let
    columns = Record.Field(_parameter, "columns"), //list

    fnClean = (val)=> Text.Trim(Text.Clean(Text.Lower(Text.From(val)))),
    transformation = List.Transform( columns, each {_, fnClean, Text.Type}),
    normalize = Table.TransformColumns(source, transformation)
in
    normalize