/* 
    проверяем работу функции fnUnpivot
 */
let
    source = Excel.CurrentWorkbook(){[Name="unpivot"]}[Content], //загружаем таблицу для теста, см скрытый лист

    unpivot = fnUnpivot(source) //проверяем работу функции
in
    unpivot