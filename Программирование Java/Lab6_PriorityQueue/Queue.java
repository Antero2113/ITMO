import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class Queue implements PriorityQueue 
{
    private int[] q; // массив для хранения элементов очереди
    private int size; // количество элементов в очереди
    private ReentrantLock lock; // блокировка для обеспечения потокобезопасности
    private Condition notFull; // условие для ожидания освобождения позиций в очереди
    private Condition notEmpty; // условие для ожидания появления значений в очереди
    private Condition Half1; // условие для ожидания значений от 1 до 5 в очереди
    private Condition Half2; // условие для ожидания значений от 6 до 10 в очереди


    public Queue() {
        q = new int[10]; // инициализация массива размером 10
        size = 0; // установка значения 0, так как очередь пуста
        lock = new ReentrantLock(); // создание объекта ReentrantLock для обеспечения синхронизации
        notFull = lock.newCondition(); 
        notEmpty = lock.newCondition(); 
        Half1 = lock.newCondition(); 
        Half2 = lock.newCondition(); 
    }


    public void insert(int val) throws InterruptedException {
        lock.lock(); // блокировка потока
        try {
            while (full()) { // пока очередь заполнена (нет места, чтобы добавить значение)
                notFull.await(); // поток отдает монитор по условию блокировки "нет свободных мест"
            }
            int cur = size; // начало сортировки, сохраняем значение size
            q[size++] = val; // добавление значения в очередь

            while (cur > 0 && q[cur] > q[(cur - 1) / 2]) { // сортировка бинарного дерева: пока "лист" больше чем родитель
                replace(cur, (cur - 1) / 2); // меняем местами "лист" и родителя
                cur = ((cur - 1) / 2); // продвигаемся выше по дереву
            }

            // System.out.println("Поток занёс значение " + Thread.currentThread().getName() + val); // уведомление о действии потока
            print(); // вывод состояния очереди
            notEmpty.signalAll(); // после добавления значения сигнализируем потокам, у которых был вызван последний await, что они могут продолжать работу (зайти в монитор)
            Half1.signalAll(); // сигнализируем потокам-потребителям, что добавлено новое значение в очередь (диапазон 1-5)
            Half2.signalAll(); // сигнализируем потокам-потребителям, что добавлено новое значение в очередь (диапазон 6-10)
        } finally {
            lock.unlock(); // разблокировка потока
        }
    }


    public int deleteMax() throws InterruptedException {
        lock.lock(); // блокировка потока
        try {
            while (empty()) { // пока очередь пустая (нет значения для извлечения)
                notEmpty.await(); // поток отдает монитор 
            }
            if (Thread.currentThread().getName().equals("6")) { // определяем, какие значения потребляет поток
                while (q[0] < 6) { // проверяем, соответствуют ли значения в очереди этому потоку
                    Half1.signal(); // сигнал другому потоку-потребителю, что он может потенциально извлечь свое значение
                    Half2.await(); // отдаем монитор, если значение не подходит
                }
            } else { // определяем, какие значения потребляет поток
                while (q[0] >= 6) { // проверяем, соответствуют ли значения в очереди этому потоку
                    Half2.signal(); // сигнал другому потоку-потребителю, что он может потенциально извлечь свое значение
                    Half1.await(); // отдаем монитор, если значение не подходит
                }
            }
            int res = q[0]; // присвоить в res извлекаемое значение
            size--; // понизить size (забрали одно значение)
            q[0] = q[size]; // заменить на последний элемент в очереди
            int current = 0; // сортировка бинарного дерева
            while (current * 2 + 1 < size) { // проходимся по всем листьям
                int max;
                int left = current * 2 + 1; // левый лист
                int right = current * 2 + 2; // правый лист
                if (right < size && q[right] > q[left]) // найти максимальный лист
                    max = right;
                else
                    max = left;
                if (q[current] < q[max]) { // если родитель меньше, чем лист
                    replace(current, max); // иначе меняем местами родителя и лист
                    current = max; // продвигаемся ниже
                } else {
                    break; // если родитель больше, чем лист, то завершить перебор
                }
            }
            // System.out.println("Поток " + Thread.currentThread().getName() + " извлёк значение " + res); // уведомление о действии потока
            print(); // вывод состояния очереди

            notFull.signalAll(); // после извлечения значения сигнализируем потокам, у которых был вызван последний await, что они могут продолжать работу (зайти в монитор)

            return res; // вернуть извлеченное значение
        } finally {
            lock.unlock(); // разблокировка потока
        }
    }

    public boolean full(){
        return size == 10;
    }

    public boolean empty(){
        return size == 0;
    }

    private void replace(int p1, int p2){
        int s = q[p1]; // промежуточная переменная с адресом
        q[p1] = q[p2]; // меняем местами
        q[p2] = s;
    }

    private void print() {
        System.out.print("Очередь: "); // вывод заголовка для очереди
        for (int i = 0; i < size; i++) {
            System.out.printf("%3s", q[i]); // вывод актуальных элементов очереди с выравниванием
        }
        System.out.println(); // переход на новую строку после вывода очеред
    }
}