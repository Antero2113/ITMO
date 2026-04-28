
class PartiallyOrderedSet {
    private Element head; // начало списка, реализующего множество
    private Element sorted_head; // начало списка, реализующего отсортированное множество
    private int ElementCount; // кол-во численных значений в множестве 

    // Класс элемента списка
    private class Element {
        protected int value; // численное значение
        protected Element next; // следующий элемент списка
        protected int inDegree; // кол-во входящих связей
        protected OutLink outLinks; // ссылка на первую исходящую связь

        // Конструктор (передаётся значение)
        Element(int value) {
            this.value = value;
            this.next = null;
            this.inDegree = 0;
            this.outLinks = null;
        }
    }

    // Класс исходящей связи элемента множества
    private class OutLink {
        protected Element target; // ссылка на элемент, которому текущий предшествует
        protected OutLink next; // ссылка на следующую связь (если есть)

        // Конструктор (передаётся элемент для связи, следующая связь null)
        OutLink(Element target) {
            this.target = target;
            this.next = null;
        }
    }

    // Метод для инициализации частично упорядоченного множества
    public boolean initialize(int[][] pairs) {
        head = null;
        ElementCount = 0;

        // Для каждой пары
        for (int[] pair : pairs) {
        	// Если нарушено условие иррефлексивности
            if (pair[0] == pair[1]) {
            	// Обнуляем все ранее полученные пары
                head = null;
                return false;
            }
            // Пробуем добавить новые элементы (если какое-то значение уже было добавлено,
            // мы получим ссылку на него, иначе на новый элемент)
            Element from = findOrCreateElement(pair[0]);
            Element to = findOrCreateElement(pair[1]);
            
            // Добавим связь между элементами
            addLink(from, to);
        }
        return true;
    }

    // Метод для добавления связи
    // Получает на вход ссылки на 2 элемента
    private void addLink(Element from, Element to) {
    	// Создаём новый объект исходящей связи, передавая to
        OutLink newLink = new OutLink(to);
        newLink.next = from.outLinks;
        from.outLinks = newLink;
        to.inDegree++;
    }

    // Вспомогательный метод для добавления элемента или получения ссылки на существующий
    private Element findOrCreateElement(int value) {
    	// Пытаемся найти значение среди имеющихся элементов
        Element element = findElement(value);
        // Если такого не было, добавляем его в начало списка
        if (element == null) {
            element = new Element(value);
            element.next = head;
            head = element;
            ElementCount++;
        }
        // Если нашли существующее, возвращаем ссылку на него, либо новый
        return element;
    }

    // Вспомогательный метод для поиска значения в множестве
    private Element findElement(int value) {
        Element current = head;
        // С головы проходим по всему списку
        while (current != null) {
        	// Если элемент нашли, возвращаем ссылку на него        }
            if (current.value == value) {
                return current;
            }
            current = current.next;
        }
        // Если такого значения не было, возвращаем null
        return null;
    }
 

    public boolean topologicalSort() {
        if (head == null) {
            return false;
        }

        sorted_head = null;
        Element lastSorted = null;
        int remainingElements = ElementCount;

        while (remainingElements > 0) {
            Element current = head;
            Element prev = null;
            Element candidate = null;
            Element prevCandidate = null;

            // Ищем первый элемент с inDegree = 0
            while (current != null) {
                if (current.inDegree == 0) {
                    candidate = current;
                    prevCandidate = prev;
                    break;
                }
                prev = current;
                current = current.next;
            }

            // Если не нашли - есть цикл
            if (candidate == null) {
                return false;
            }

            // Добавляем в отсортированный список
            if (sorted_head == null) {
                sorted_head = new Element(candidate.value);
                lastSorted = sorted_head;
            } else {
                lastSorted.next = new Element(candidate.value);
                lastSorted = lastSorted.next;
            }

            // Уменьшаем inDegree для всех соседей
            OutLink outLink = candidate.outLinks;
            while (outLink != null) {
                outLink.target.inDegree--;
                outLink = outLink.next;
            }

            // Удаляем элемент из списка 
            if (prevCandidate == null) {
                head = candidate.next;
            } else {
                prevCandidate.next = candidate.next;
            }

            remainingElements--;
        }

        return true;
    }

    public void printSortedOrder() {
        Element current = sorted_head;
        System.out.print("Топологический порядок: ");
        while (current != null) {
            System.out.print(current.value + " ");
            current = current.next;
        }
        System.out.println();
    }
}
