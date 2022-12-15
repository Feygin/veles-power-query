/* 
    трансформируем столбцы с периодами в строки (unpivot)
 */
(source)=>
let
    // [
        SEPARATOR = "^", //разделитель многострочной шапки
        MULTIHEADER_ROWS = {"показатель", "дата", "идентификатор"}, //поля многостррчной шапки

        //список столбцов для unpivot
        //определяем принадлежность стобца по разделителю многострочной шапки
        columns_to_unpivot = List.Select(Table.ColumnNames(source), each Text.Contains(_, SEPARATOR)), 
        unpivot = Table.Unpivot(source, columns_to_unpivot, "аттрибут", "значение"), //преобразовываем столбцы в строки
        filter_nulls = Table.SelectRows(unpivot, each ([значение] <> 0) and ([значение] <> null) and ([значение] <> "")), //исключаем строки без значений
        //разделяем многострочную шапку по столбцам
        split_multiheader = Table.SplitColumn(filter_nulls, "аттрибут", Splitter.SplitTextByDelimiter("^", QuoteStyle.Csv), MULTIHEADER_ROWS), 
        //трансформируем аттрибуты периода в столбцы
        pivot = Table.Pivot(split_multiheader, List.Distinct(split_multiheader[показатель]), "показатель", "значение", List.Sum),
        //если в шапке в блоке с датами были столбцы с одинаковыми названиями, например, два столбца факт^часы факт^01.06.2018^
        //тогда для того, чтобы различать столбцы между собой power query добавляет идентификатор _n:
        //факт^часы факт^01.06.2018^, факт^часы факт^01.06.2018^_1
        //этот шаг удаляет этот идентификатор
        extract_text_from_dup_attributes= Table.TransformColumns(pivot, {{"идентификатор", each Text.BeforeDelimiter(_, "_"), type text}})
    // ]
in
    extract_text_from_dup_attributes