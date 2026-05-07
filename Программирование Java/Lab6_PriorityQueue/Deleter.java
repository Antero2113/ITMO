
public class Deleter implements Runnable {
    private Queue queue;
    String min;

    public Deleter(Queue queue, int n) {
        this.queue = queue;
        if (n==1||n==6){
            min = String.valueOf(n);
            new Thread(this, min).start(); // инициализация и запуск потока 1-5
        }
        else throw new IllegalArgumentException("Invalid MIN value"); // выброс исключения при недопустимом значении MIN
    }

    public void run() {
        while (true) {
            try {
                queue.deleteMax(); // извлечение значения из очереди
                Thread.sleep(200); // задержка на 0.2 секунды
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt(); // прерывание потока
            }
        }
    }

}
