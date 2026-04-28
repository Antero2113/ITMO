
public class Main {
	public static void main(String args[]) {

		Integer arr1[]=new Integer [10];//делаем строчный массив на 10 символов
		AbstractList<Integer> list1= new AbstractList<>(arr1);//делаем список для строчного типа данных  передавая в пармаетры конструктора строчный массив
		list1.Insert(1, list1.End());
		list1.Insert(1, list1.End());
		list1.Insert(1,list1.End());
		list1.Insert(4,list1.End());
		list1.Insert(5, list1.End());
       list1.PrintList();
        deleteDuplicats(list1);
        list1.PrintList();
		
		String arr2[]=new String [10];//делаем строчный массив на 10 символов
		AbstractList<String> list2= new AbstractList<>(arr2);//делаем список для строчного типа данных  передавая в пармаетры конструктора строчный массив
		list2.Insert("один", list2.End());
        list2.Insert("один", list2.End());
        list2.Insert("два", list2.End());
        list2.Insert("пять", list2.End());	
        list2.PrintList();
        deleteDuplicats(list2);
        list2.PrintList();
    
        R arr3[]=new R [10];
        AbstractList<R> list3= new AbstractList<>(arr3);
        list3.Insert(new R(0,-6), list3.End());
        list3.Insert(new R(1,-6), list3.End());
        list3.Insert(new R(12,-6), list3.End());
        list3.Insert(new R(21,6), list3.End());
        list3.PrintList();
        deleteDuplicats(list3);
        list3.PrintList();

	}

    public static <T extends Comparable<T>> void deleteDuplicats(AbstractList<T> ls) {
		int a1=ls.First();
		int b; // Создаём переменные для прохода и сравнения всех элементов списка
		while(a1 != ls.End()){
			b = ls.Next(a1);
			while(b != ls.End()){ // Пока не дошли до конца
				if(ls.Retrieve(a1).compareTo(ls.Retrieve(b)) == 0){ // Сравниваем элементы
					b=ls.Previous(b); //Сдвигаем переменную
					ls.Delete(ls.Next(b));//Удаляем повтор
				}
				b=ls.Next(b);		
			}
			a1=ls.Next(a1);			
		}
	}
}
