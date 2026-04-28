public class AbstractList <T extends Comparable<T>> {
	private int firstFree=0;	//первый свободный элемент списка
	private T[] array;		//массив для реализации списка
	
    //конструктор списка
	public AbstractList(T[] array) {		
		this.array=array;
	}

    //возвращает позицию после последнего
	public int End() {		
		return firstFree;
	}

    //вставляет значение в позицию
	public void Insert(T t, int index) {			
		if(index<0 && index>firstFree)
			return;		//если индекс меньше 0 и больше позиции после последнего+1 ничего не делаем
		firstFree++;//firstFree++ (сдвигаем номер последнего элемента)
		for(int i=firstFree-1; i>index; i--)//делаем firstFree раз от firstFree до index (цикл фор)
			array[i]=array[i-1];//i позиция массива значений=i-1 позиции 
		array[index]=t; //помещаем элемент t в массив значений на позицию с индексом index
	}

    //возвращает позицию в которой хранится значение
	public int Locate(T t) { 		
		int p=0;//создаем переменную результата
		for(T i:array){//в цикле for each для array:
			if(i.compareTo(t) == 0)//если элемент из массива = объекту полученного в аргументах (методом compareTo(если метод вернет 0 элементы равны))
				return p;//вернуть переменную результата
			p++;	//увеличить переменную результата на один
		}
		return firstFree;
	}

    //возвращает значение в позиции
	public T Retrieve (int index) {	
		if(index<0 || index>=firstFree)//если index<0 || index>=firstFree 
			throw new MyListIndexOutOfBoundException("Нет такой позиции");//выбрасываем исключение
		return array[index]; //возвращаем индексированный элемент массива
	}

    //удаляет значение в позиции
	public void Delete(int index) {		
		if (index<0 || index>=firstFree)
			return;		//если index<0 || index>=firstFree выходим из метода
		for (int i=index+1; i<firstFree; i++)//цикл фор(делаем firstFree раз от index до firstFree)
			array[i-1]=array[i];//помещаем i-ый элемент массива в i-1 ячейку массива
		firstFree--;//уменьшаем firstFree на еденицу 
	}

    //возвращает следующую позицию в списке
	public int Next(int index)  {	
		if (index<0 || index>firstFree) //если index+1<0 || index+1>firstFree 
			throw new MyListIndexOutOfBoundException("Нет такой позиции");//выбрасываем исключение
		return index+1; //вернуть индекс+1
	}

    //возвращает предыдущую позицию в списке
	public int Previous(int index) {		
		if(index<=0 || index>=firstFree) //если index-1<0 || index-1>firstFree 
			throw new MyListIndexOutOfBoundException("Нет такой позиции");//выбрасываем исключение
		return index-1; //вернуть индекс-1
	}

    //делает пустой список
	public void Makenull() {	
		firstFree=0;	//firstFree=0 
	}
	public int First() {		//возвращает позицию первого элемента
		return 0;
	}

    //вывод списка 
	public void PrintList() {		
		System.out.print("( ");//вывести символ скобки(с пробелом)
		if (firstFree==0)//если firstFree=0
			System.out.print(") ");//вывести символ скобки(закрывающейся) 
		for(int i=0; i<firstFree-1; i++){//цикл фор(firstFree раз от 0 до firstFree)
			System.out.print(array[i] + " ,");//вывести i-ый элемент с запятой на конце
	}
		System.out.print(array[firstFree -1] + " )\n");//вывести i-ый элемент массива со скобкой на конце 
}
}

//класс исключения
class MyListIndexOutOfBoundException extends RuntimeException{		
     String ms;

	 public MyListIndexOutOfBoundException(String ms) {
		this.ms = ms;
	 }
     public String toString(){
         return ms;
     }
}
