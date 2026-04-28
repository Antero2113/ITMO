
public class main {
    public static void main(String[] args) {
        // int[][] pairs = {{1, 2}, {2, 3}, {1, 3}};
        int[][] pairs = {{1, 2}, {2, 4}, {4, 6}, {2, 10}, {4, 8}, {6, 3}, {1, 3}, {3, 5}, {5, 8}, {7, 5}, {7, 9}, {9, 4}, {9, 10}, {6, 1}};
        
        PartiallyOrderedSet poset = new PartiallyOrderedSet();
        if (poset.initialize(pairs)) {
            if (poset.topologicalSort()) {
                System.out.println("Топологическая сортировка выполнена успешно.");
                poset.printSortedOrder();
            } else {
                System.out.println("Обнаружен цикл. Топологическая сортировка невозможна.");
            }
        } else {
            System.out.println("Нарушено свойство иррефлексивности. Инициализация прервана.");
        }
    }
}