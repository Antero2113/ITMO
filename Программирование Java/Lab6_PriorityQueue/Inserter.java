import java.util.Random;

public class Inserter implements Runnable {
    private Queue queue;
    private Random random = new Random();

    public Inserter(Queue queue) {
        this.queue = queue;
        new Thread(this).start(); // инициализация и запуск потока
    }

    public void run() {
        while (true) {
            try {
                int k = random.nextInt(1, 3); // генерация случайного значения от 1 до 3 (количество итераций)
                for (int i = 0; i < k; i++) {
                    int val = random.nextInt(1, 11); // генерация случайного значения от 1 до 10 (добавляемое значение)
                    queue.insert(val); // добавление значения в очередь
                }
                Thread.sleep(500); // задержка выполнения потока на 0.5 секунды
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt(); // прерывание потока
            }
        }
    }


}

