
public class StudentCourseRelation {
    private static int size = 100; // размер массивов для курсов и студентов
    private Record[] students; // массив объектов Record (студенты)
    private Record[] courses; // массив объектов Record (курсы)
    
    // Конструктор по умолчанию - инициализация массивов
    public StudentCourseRelation() {
        students = new Record[size];
        courses = new Record[size];
    }
    
    // Абстрактный класс для организации наследования
    abstract class Record {
    	// метод для различения студентов, курсов и регистрационных записей
        public abstract boolean isRegistration();
    }
    
    // Класс студентов
    private class Student extends Record {
        protected char[] name; // имя
        protected Record next; // ссылка на запись, если есть
        
        // Конструктор по умолчанию (имя и пустая ссылочная переменная)
        public Student(char[] name) {
            this.name = name;
            this.next = null;
        }
        
        @Override
        public boolean isRegistration() {
            return false; // не является регистрационной записью
        }
    }
    
    // Класс курсов
    private class Course extends Record {
        int courseId; // идентификатор курса
        Record next; // ссылка на запись, если есть
        
        // Конструктор по умолчанию (идентификатор и пустая ссылочная переменная)
        public Course(int courseId) {
            this.courseId = courseId;
            this.next = null;
        }
        
        @Override
        public boolean isRegistration() {
            return false; // не является регистрационной записью
        }
    }
    
    // Класс для создания регистрационных записей
    private class Registration extends Record {
        Record red;   // Ссылка на студента или следующую регистрацию
        Record black; // Ссылка на курс или следующую регистрацию
        
        // В конструктор передаём ссылки на объекты Record
        public Registration(Record red, Record black) {
            this.red = red;
            this.black = black;
        }
        
        @Override
        public boolean isRegistration() {
            return true; // является регистрационной записью
        }
    }
    
    // Сравнение char[]
    private static boolean charsEqual(char[] arr1, char[] arr2) {
        if (arr1 == arr2) return true;
        if (arr1 == null || arr2 == null) return false;
        if (arr1.length != arr2.length) return false;
        
        for (int i = 0; i < arr1.length; i++) {
            if (arr1[i] != arr2[i]) {
                return false;
            }
        }
        return true;
    }
    
    // ХЕШИРОВАНИЕ  И ПОИСК
    
    // Отдельно подсчёт суммы кодов символов, а для хеширования одна функция с num от 0
    private int sum(char[] x) {
    	// Сумма кодов символов, составляющих имя
    	int sum = 0;
        for (char c : x) {
            sum += (int) c; // Преобразуем символ в его ASCII-код и добавляем к сумме
        }
        return sum;
    }
    
    // Хэш-функция для курсов и студентов
    private int hashFunction(int sum, int num) {
        // возвращаем остаток от деления суммы + итерации на размер доступных массивов
        return (sum + num) % size;
    }
    
    // Вспомогательный метод для поиска студента
    private int findStudentIndex(char[] name) {
    	// Находим сумму символов имени
    	int sum = sum(name);
    	int c = 0;
    	// Вызываем хэш-функцию для первой подходящей ячейки
        int index = hashFunction(sum, c);
        // Запоминаем, откуда начали перебор
        int startIndex = index;
        
        // Пока не дошли до пустой и не нашли совпадения 
        while (students[index] != null && !(charsEqual(((Student)students[index]).name, name))) 
        {
        	// Увеличиваем счётчик и вызываем хэш-функцию повторно
            c ++;
            index = hashFunction(sum, c);
            // Если вернулись в начало, возвращаем -1
            if (index == startIndex) return -1;
        }
        // Если нашли, возвращаем индекс
        if (students[index] != null) return index;
        // Если вышли из цикла и не нашли, возвращаем -1
        else return -1;
    }
    
 // Вспомогательный метод для поиска курса
    private int findCourseIndex(int courseId) {
    	int c = 0;
    	// Вызываем хэш-функцию для первой подходящей ячейки
        int index = hashFunction(courseId, c);
        // Запоминаем, откуда начали перебор
        int startIndex = index;
        
        // Пока не дошли до пустой и не нашли совпадения 
        while (courses[index] != null && !(((Course)courses[index]).courseId == courseId))
        {
        	// Увеличиваем счётчик и вызываем хэш-функцию повторно
        	c ++;
            index = hashFunction(courseId, c);
            // Если вернулись в начало, возвращаем -1
            if (index == startIndex) return -1;
        }
        // Если нашли, возвращаем индекс
        if (courses[index] != null) return index;
        // Если вышли из цикла и не нашли, возвращаем -1
        else return -1;
    }
    
    
    
    // ДОБАВЛЕНИЕ В МАССИВЫ (БЕЗ РЕГИСТРАЦИОННЫХ ЗАПИСЕЙ)
    
    // Метод для добавления студента в таблицу
    public boolean addStudent(char[] name) {
    	// Вызываем хэш-функцию для найденной суммы символов имени
    	int sum = sum(name);
    	int c = 0;
        int index = hashFunction(sum, c);
        int startIndex = index;
        
        // Ищем пустую ячейку для вставки
        while (students[index] != null) {
        	// Если студент уже есть, возвращаем false
            if (charsEqual(((Student)students[index]).name, name)) {
                return false;
            }
            // На каждой итерации увеличиваем счётчик и вызываем хэш-функцию
            c ++;
            index = hashFunction(sum, c);
            // Если вернулись в начало, всё занято, ничего не вставляем
            if (index == startIndex) return false;
        }
        // Если нашли доступную ячейку, добавляем нового студента и возвращаем true
        students[index] = new Student(name);
        return true;
    }
    
    public boolean addCourse(int courseId) {
    	// Вызываем хэш-функцию для найденной суммы символов иентификатора
    	int c = 0;
        int index = hashFunction(courseId, c);
        int startIndex = index;
        
        // Ищем пустую ячейку для вставки
        while (courses[index] != null) {
        	// Если курс уже есть, возвращаем false
            if (((Course)courses[index]).courseId == courseId) {
                return false;
            }
            // На каждой итерации увеличиваем счётчик и вызываем хэш-функцию
            c ++;
            index = hashFunction(courseId, c);
            // Если вернулись в начало, всё занято, ничего не вставляем
            if (index == startIndex) return false;
        }
        // Если нашли доступную ячейку, добавляем нового студента и возвращаем true
        courses[index] = new Course(courseId);
        return true;
    }
    
    // ДОБАВЛЕНИЯ СВЯЗИ КУРСА И СТУДЕНТА (НОВАЯ РЕГИСТРАЦИОННАЯ ЗАПИСЬ)
    
    // Метод для связывания студента и курса, добавления студента на курс
    // Возвращает true в случае успеха и false в случае неуспеха
    public boolean addStudentToCourse(char[] studentName, int courseId) {
    	// Проверяем, есть ли уже в таблице курс и студент
        int studentIndex = findStudentIndex(studentName);
        int courseIndex = findCourseIndex(courseId);
        
        // Если таких нет, создание записи невозможно
        if (studentIndex == -1 || courseIndex == -1) return false;
        
        // В новый объект рег записи помещаем ссылки на курс и на студента
        Student student = (Student)students[studentIndex];
        Course course = (Course)courses[courseIndex];
        Registration reg = new Registration(student, course);
     
        
        // Добавляем связь со стороны курса
        if (course.next == null) // Если раньше на курсе не числилось студентов
        { 
            course.next = reg; // Помещаем в next ссылку на первую рег запись этого курса
            reg.black = course;
        } 
        else { // Если ранее уже были добавлены студенты на этот курс
            reg.black = course.next; // Новую рег запись связываем с предыдущей 
            course.next = reg; // Ссылку на новую запись оставляем в next курса
        }
        
        // Добавляем связь со стороны студента
        if (student.next == null) {
            student.next = reg;
            reg.red = student; // Замыкаем цикл
        } 
        else { // Если ранее уже были добавлены курсы этому студенту
            reg.red = student.next; // Новую рег запись связываем с предыдущей записью этого студента
            student.next = reg;  // Ссылку на новую запись помещаем в  next студента
        }
        // после добавления записи возвращаем true
        return true;
    }
    
    // УДАЛЕНИЕ РЕГИСТРАЦИОННОЙ ЗАПИСИ (ОТВЯЗЫВАЕМ СТУДЕНТА ОТ КОНКРЕТНОГО КУРСА)
    
    public boolean removeStudentFromCourse(char[] studentName, int courseId) {
        // 1. Проверяем, существуют ли студент и курс
        int studentIndex = findStudentIndex(studentName);
        int courseIndex = findCourseIndex(courseId);
        
        if (studentIndex == -1 || courseIndex == -1) {
            return false; // Студент или курс не найдены
        }
        
        Student student = (Student) students[studentIndex];
        Course course = (Course) courses[courseIndex];
        
        // 2. Ищем регистрационную запись, связывающую студента и курс
        Registration targetReg = null;
        
        // Проходим по списку регистраций курса, ищем запись, где студент совпадает       
        Record currentCourseReg = course.next;
        while (currentCourseReg != null && currentCourseReg.isRegistration()) {
            Registration reg = (Registration) currentCourseReg;
            
            // Распутываем цепочку red ссылок, пока не найдём студента
            Record redRecord = reg.red;
            while (redRecord != null && redRecord.isRegistration()) {
                redRecord = ((Registration)redRecord).red;
            }
            
            if (redRecord == student) {
                targetReg = reg; // Нашли нужную запись
                break;
            }
            currentCourseReg = reg.black;
        }
        
        if (targetReg == null) {
            return false; // Связь не найдена
        }
        
        // 3. Удаляем запись из списка курса
        Record prevCourseReg = findPreviousRegistration(course.next, targetReg, false); // false = идём по black
        
        if (prevCourseReg == null) {
            course.next = targetReg.black; // targetReg был первым в списке курса
        } else {
            ((Registration) prevCourseReg).black = targetReg.black; // перелинковываем предыдущий
        }
        
        // 4. Удаляем запись из списка студента
        Record prevStudentReg = findPreviousRegistration(student.next, targetReg, true); // true = идём по red
        
        if (prevStudentReg == null) {
            student.next = targetReg.red; // targetReg был первым в списке студента
        } else {
            ((Registration) prevStudentReg).red = targetReg.red; // перелинковываем предыдущий
        }
        
        return true; // Успешно удалено
    }
    
    
    // УДАЛЕНИЕ ВСЕХ РЕГИСТРАЦИОННЫХ ЗАПИСЕЙ СТУДЕНТА (НЕ ЧИСЛИТСЯ НА КУРСАХ)      
    
    public boolean removeStudent(char[] studentName) {
        int studentIndex = findStudentIndex(studentName);
        if (studentIndex == -1) return false;
        
        Student student = (Student) students[studentIndex];
        Record currentReg = student.next;
        
        // Удаляем все регистрационные записи студента из связанных курсов
        while (currentReg != null && currentReg.isRegistration()) {
            Registration reg = (Registration) currentReg;
            Course course = (Course) reg.black;
            
            
            // Находим предыдущую запись перед reg в списке курса
            Record prevCourseReg = findPreviousRegistration(course.next, reg, false);
            
            // Удаляем reg из списка курса
            if (prevCourseReg == null) {
                course.next = reg.black; // reg был первым в списке
            } else {
                ((Registration) prevCourseReg).black = reg.black;
            }
            
            currentReg = reg.red;
            student.next = currentReg;
            
        }

        return true;
    }
    
    // УДАЛЕНИЕ ВСЕХ РЕГИСТРАЦИОННЫХ ЗАПИСЕЙ КУРСА (НА КУРСЕ НЕТ СТУДЕНТОВ)

    public boolean removeCourse(int courseId) {
    	// Проверяем существование курса
        int courseIndex = findCourseIndex(courseId);
        if (courseIndex == -1) return false;
        
        Course course = (Course) courses[courseIndex];
        Record currentReg = course.next;
        
        // Удаляем все регистрационные записи курса из связанных студентов
        while (currentReg != null && currentReg.isRegistration()) {
            Registration reg = (Registration) currentReg;
            Student student = (Student) reg.red;
            
            // Находим предыдущую запись перед reg в списке студента
            Record prevStudentReg = findPreviousRegistration(student.next, reg, true);
            
            // Удаляем reg из списка студента
            if (prevStudentReg == null) {
                student.next = reg.red; // reg был первым в списке
            } else {
                ((Registration) prevStudentReg).red = reg.red;
            }
            
            currentReg = reg.black;
            course.next = currentReg;
            
        }
        
        return true;
    }
    
    
    // Возвращает предыдущий элемент перед targetReg в списке, начинающемся с head.
    // Если targetReg — первый элемент, возвращает null (предыдущего нет).
     private Record findPreviousRegistration(Record head, Registration targetReg, boolean isRedChain) {
         Record prev = null;
         Record current = head;
     
         while (current != null && current.isRegistration()) {
             Registration reg = (Registration) current;
         
             if (reg == targetReg) {
                 return prev; // Нашли искомую запись, возвращаем предыдущий
             }
         
             prev = current;
             // Выбираем следующую ссылку в зависимости от направления обхода (red или black)
             current = isRedChain ? reg.red : reg.black;
         }
     
         return null; // Не нашли запись (невозможно при корректных данных)
     }

    
    // МЕТОДЫ ДЛЯ ВЫВОДА КУРСОВ СТУДЕНТА ИЛИ СТУДЕНТОВ КУРСА
    
    // Вывод всех студентов курса
     public void printStudentsOfCourse(int courseId) {
    	    // Проверка на существование курса
    	    int courseIndex = findCourseIndex(courseId);
    	    if (courseIndex == -1) {
    	        System.out.println("Курс не найден");
    	        return;
    	    }
    	    
    	    Course course = (Course)courses[courseIndex];
    	    Record current = course.next;
    	    
    	    System.out.println("Студенты курса " + courseId + ":");
    	    
    	    // Проходим по всем регистрационным записям курса
    	    while (current != null && current.isRegistration()) {
    	        Registration reg = (Registration)current;
    	        
    	        // Распутываем цепочку red ссылок, пока не найдём студента
    	        Record redRecord = reg.red;
    	        while (redRecord != null && redRecord.isRegistration()) {
    	            redRecord = ((Registration)redRecord).red;
    	        }
    	        
    	        // Если нашли студента - выводим его
    	        if (redRecord != null && !redRecord.isRegistration()) {
    	            Student student = (Student)redRecord;
    	            System.out.println(String.valueOf(student.name));
    	        }
    	        
    	        current = reg.black;
    	    }
    	    System.out.println("");
    	}
   
    
    public void printCoursesOfStudent(char[] studentName) {
        // Проверка на существование студента
        int studentIndex = findStudentIndex(studentName);
        if (studentIndex == -1) {
            System.out.println("Студент не найден");
            return;
        }
        
        Student student = (Student)students[studentIndex];
        Record current = student.next;
        
        System.out.println("Курсы студента " + String.valueOf(studentName) + ":");
        
        // Проходим по всем регистрационным записям студента
        while (current != null && current.isRegistration()) {
            Registration reg = (Registration)current;
            
            // Распутываем цепочку black ссылок, пока не найдём курс
            Record blackRecord = reg.black;
            while (blackRecord != null && blackRecord.isRegistration()) {
                blackRecord = ((Registration)blackRecord).black;
            }
            
            // Если нашли курс - выводим его
            if (blackRecord != null && !blackRecord.isRegistration()) {
                Course course = (Course)blackRecord;
                System.out.println(course.courseId);
            }
            
            current = reg.red;
        }
        System.out.println("");
    }
    
    // УДАЛЕНИЕ ИЗ МАССИВА НАВСЕГДА (не используется)
    
    public void removeCourseFromArray(int id)
    {
    	int index = findCourseIndex(id);
    	if (index != -1) courses[index] = null;
    }
    
    public void removeStudentFromArray(char[] n)
    {
    	int index = findStudentIndex(n);
    	if (index != -1) students[index] = null;
    }
}
