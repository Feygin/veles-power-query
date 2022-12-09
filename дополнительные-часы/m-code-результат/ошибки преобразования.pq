/* 
    выводим в отдельный шаг ошибки в данных
    они могут быть в исходниках или gjzdbnmcz при трансформациях
    нпример, при изменении типа данных number_from('text') -> err
 */
let
    source = #"_объединяем_данные", //ссылка на предыдущий шаг
    get_errors = fnCheckTableForErrors(source, [columns = {"имя файла"}]), //извлекаем ошибки преобразованя
    filter_errors = Table.SelectRows(get_errors, each [содержит ошибку] = true) //исключаем пустые строки без ошибок, появляются если в файле не было ошибок
in
    filter_errors