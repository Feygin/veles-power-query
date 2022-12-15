/* 
    проверяем работу функции fnUnfoldHierarchy
 */
let
    source = Excel.CurrentWorkbook(){[Name="hierarchy"]}[Content], //загружаем таблицу для теста, которая располагается на скрытом листе книги
    unfold_hierarchy = fnUnfoldHierarchy(source, 5, "индекс иерархия", "ркц описание") //проверяем работу функции
in
    unfold_hierarchy