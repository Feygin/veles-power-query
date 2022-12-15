/* 
    проверяем работу функции fnUnpivot на файле который должен выдать ошибку
 */
let
    source = Excel.CurrentWorkbook(){[Name="unpivot__DupHeader"]}[Content], //загружаем таблицу для теста, см скрытый лист

    unpivot = fnUnpivot(source), //проверяем работу функции
    err = (try unpivot)[Error] //выводим ошибку
in
    err