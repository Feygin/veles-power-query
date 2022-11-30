
/* 
    цель: 
        заменяет символы в полях таблицы
    параметры:
        columns - список столбцов в которых производим замену символом
        replacement - список пар символов для замены, первый в паре - что заменяем, второй в паре - на что заменяем
    результат:
        таблица с замененными символами с столбцах
    основные операции:
        преобразовывает значения в текст и производит заменую совпадающих символов в словах по столбцам таблицы
    
 */
 (source, _parameter as record) =>
    let
        columns = Record.Field(_parameter, "columns"),
        replacement = Record.FieldOrDefault(_parameter, "replacement", {{".", ","}}),

        columns_buffer = List.Buffer(columns), //добавляем список столбцов для замены в буфер  
        fnReplaceMatchingSymbols = //функция для замены совпадающего символа в однобуквенном литерале
            (replacement)=>
                (val)=>
                    List.ReplaceMatchingItems({val}, replacement){0},
        fnReplaceMatchingSymbolsInText = //функция для замены символов в многобуквенном литерале
            (replacement)=>
                (val)=>
                    let
                        val_to_text = Text.From(val), //преобразовываем значение в текст
                        get_text_symbols = Text.ToList(val_to_text), //преобразовываем текст в список
                        replace_symbols = List.Transform(get_text_symbols, fnReplaceMatchingSymbols(replacement)), //заменяем совпадающие символы в списке
                        combine_text = Text.Combine(replace_symbols), //собираем список обратно в текст
                        check_if_null = if val = null then null else combine_text //для предотвращения ошибки проверяем исходную переменную на null
                    in
                        check_if_null,
        transformation = List.Transform( //генерируем список трансформаций для таблицы 
            columns_buffer, 
            each {_, fnReplaceMatchingSymbolsInText(replacement), type text}
        ), 
        replace_symbols = Table.TransformColumns(source, transformation) //заменяем символы в столбцах
    in
        replace_symbols