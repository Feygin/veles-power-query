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
        fnPivotFunction = //функция для агррегации значений при pivot
            (pivot_result)=>
                if List.Count(pivot_result) <= 1 then //если дубликатов строк нет, выводим результирующее значение
                    List.First(pivot_result) //List.Count = 0 если результирующие значения отсутствуют, при этом List.First выдаст null
                else //в противном случае выводим ошибку
                    "Ошибка: не допускается наличие двух одинаковых строк.#(cr)"
                    & "Добавте уникальный идентификатор, например, индекс.",
        //трансформируем аттрибуты периода в столбцы
        pivot = Table.Pivot(split_multiheader, List.Distinct(split_multiheader[показатель]), "показатель", "значение", fnPivotFunction),
        //если в шапке в блоке с датами были столбцы с одинаковыми названиями, например, два столбца факт^часы факт^01.06.2018^
        //тогда для того, чтобы различать столбцы между собой power query добавляет идентификатор _n:
        //факт^часы факт^01.06.2018^, факт^часы факт^01.06.2018^_1
        //этот шаг удаляет этот идентификатор
        extract_text_from_dup_attributes= Table.TransformColumns(pivot, {{"идентификатор", each Text.BeforeDelimiter(_, "_"), type text}})
    // ]
in
    extract_text_from_dup_attributes