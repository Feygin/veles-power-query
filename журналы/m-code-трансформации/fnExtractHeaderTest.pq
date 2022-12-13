/* 
    проверяем работу функции fnExtractHeader
 */
let
    source_valid = Excel.CurrentWorkbook(){[Name="customHeaderValid"]}[Content], //загружаем таблицу для теста (находится на скрытом листе)
    extract_header_valid = fnExtractHeader(source_valid) //применям функцию fnExtractHeader
in
    extract_header_valid