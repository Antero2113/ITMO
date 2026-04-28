public class Main {
    public static void main(String[] args){
        Queue queue = new Queue();
        Inserter p1 = new Inserter(queue);
        Inserter p2 = new Inserter(queue);
        Deleter p3 = new Deleter(queue, 1);
        Deleter p4 = new Deleter(queue, 6);
    }
}

