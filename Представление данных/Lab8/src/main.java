public class main {
    public static void main(String[] args) {
        StudentCourseRelation relation = new StudentCourseRelation();
        
        // Заполнение тестовыми данными
        fillStudents(relation);
        fillCourses(relation);
        
        // Тестирование операций
        relation.addStudentToCourse(stringToCharArray("Аня"), 101);    
        relation.addStudentToCourse(stringToCharArray("Иван"), 101);   
        relation.addStudentToCourse(stringToCharArray("Аня"), 202);    
        relation.addStudentToCourse(stringToCharArray("Аня"), 303); 
        relation.addStudentToCourse(stringToCharArray("Ольга"), 202); 
        
        relation.printCoursesOfStudent(stringToCharArray("Аня"));
        relation.printStudentsOfCourse(101);
        
        relation.removeStudent(stringToCharArray("Аня"));
        relation.printCoursesOfStudent(stringToCharArray("Аня"));
        
        relation.removeCourse(101);
        relation.printStudentsOfCourse(101);
        
        relation.printCoursesOfStudent(stringToCharArray("Иван"));
        
        
//        relation.printStudentsOfCourse(101);  
//        relation.printCoursesOfStudent(stringToCharArray("Аня"));
//        
//        relation.removeStudentFromCourse(stringToCharArray("Аня"), 101);
//        relation.printStudentsOfCourse(101);
//        
//        relation.removeStudent(stringToCharArray("Иван"));
//        relation.printStudentsOfCourse(101);
//        
//        relation.removeCourse(202);  
//        relation.printCoursesOfStudent(stringToCharArray("Аня"));
    }
    
    // Вспомогательный метод для преобразования String в char[]
    private static char[] stringToCharArray(String str) {
        return str.toCharArray();
    }
    
    private static void fillStudents(StudentCourseRelation relation) {
        String[] testStudents = {"Аня", "Иван", "Мария", "Петр", "Ольга"};
        for (String name : testStudents) {
            relation.addStudent(stringToCharArray(name));
        }
    }
    
    private static void fillCourses(StudentCourseRelation relation) {
        int[] testCourses = {101, 202, 303, 404, 505};
        for (int courseId : testCourses) {
            relation.addCourse(courseId);
        }
    }
}