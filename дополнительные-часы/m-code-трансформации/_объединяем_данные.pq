/* 
    объединяем таблицы с дополнительными часами, изменяем тип данных
 */
let
    source = #"_извлекаем_содержимое", //результат шага #"_извлекаем_содержимое"
    select_data = Table.SelectColumns(source, {"имя файла", "PrepareData"}), //оставляем поле с именем файла и содержимым 

    expand_columns = Table.ExpandTableColumn( //разкрываем содержимое таблицы
        select_data, 
        "PrepareData", 
        {
            "дата",
            "проект",
            "подпроект",
            "организация",
            "классификатор",
            "работа описание",
            "работа группа",
            "типовые",
            "часы",
            "стоимость руб"
        }
    ),
    replace_dots_in_nums = fnReplaceSymbols( //заменяем "." на "," в числовых столбцах, чтобы при преобразовании
        expand_columns, columns = {"часы", "стоимость руб"}, replacement = {{".", ","}} //типа данных не появились ошибки
    ), 
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных
        replace_dots_in_nums,
        {
            {"дата", type date}, 
            {"проект", type text}, 
            {"подпроект", type text}, 
            {"организация", type text}, 
            {"классификатор", type text}, 
            {"типовые", type text},
            {"часы", type number},
            {"стоимость руб", type number}
        }
    )
in
    change_dtype