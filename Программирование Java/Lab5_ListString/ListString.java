public class ListString {
	
	private static class StringItem
	{
		private final static byte SIZE = 16; //размер символьного массива в блоке
		private char [] symbols; //массив символов блока
		private StringItem next; //ссылка на следующий блок
		private byte size; //размер блока
		
		//Конструктор по умолчанию
		private StringItem()
		{
		symbols=null; //Инициализация переменной symbols
		size=0; //Инициализация переменной  size
		next=null;
		}

		//конструктор для создания блока из строки
		private StringItem(String string) {
		int len=Math.min(string.length(), SIZE);			//узнаем длину нашей строки для того что бы понять помещается ли строка в блок	
		if(len==SIZE){
			size=SIZE;
			symbols=string.toCharArray();		//если длина строки =16, то длина блока равна 16, а символы блока = строке
			return;							
		}
		symbols= new char [SIZE];
		copy(string.toCharArray(), symbols, 0, 0, len);			//копируем их из строки в блок (16 или меньше)
		size=(byte)len;						 //размер блока = длина строки(если она меньше блока) или длина блока(если длина строки больше блока)
		}



		private StringItem (StringItem first) { 			//копирует блок
		symbols=new char[SIZE];
		copy(first.symbols, symbols, 0, 0, first.size);		//копируем символы с помощью метода CopyArray
		size=first.size;
		next=null;								//указать, что размер копии=рахмеру оригинала и next=null
		}

		public String toString() { 		//преобразует StringItem в тип String
			return String.valueOf(symbols);		 //преобразуем символы блока в строку(String.valueOf(symbols)
		 }

		private boolean join() { //метод для проверки возможности объединения двух блоков
			 if(size+next.size>SIZE) 	//если длина текущего блока+длина следующего блока больше SIZE, то возвращаем false
				 return false;
			 int end=size+next.size;	//иначе делаем переменную end = длина текущего блока+длина следующего блока
			 copy(next.symbols, symbols, 0, size, end-size);//копируем end-длина текущего блока символов следующего блока в текущий блок, копируем с начало блока, вставляем с индекса равного длине текущего блока
			 size=(byte)end;//длина текущего блока = end
			 next=next.next;//переменная next текущего блока указывает на следующий за следующим блоком блок
			 return true;
		 }
		

		private StringItem divide(int index) {		//разделяет блок на два
			 StringItem next = this.next;		//сохраняем следующий блок в переменную next
			 StringItem blok = new StringItem();	
			 blok.symbols= new char[SIZE];
			 blok.size=(byte)(size-index);
			 copy(this.symbols, blok.symbols, index, 0, (int)blok.size);		//создаем переменную нового блока с помощью CopeArray
			 
			 size=(byte)index;			//длина текущего блока = index 
			 return blok;
		 }


		 private StringItem subblok(int start, int end) {		//делаем подблок
			 StringItem si = new StringItem();	//делаем пустой блок используя конструктор по умолчанию 
			 si.symbols = new char[SIZE];
			 copy(symbols, si.symbols, start, 0, end - start);//копируем end-start символов в пустой блок из текущего, копируем с start вставляем с 0
			 si.size=(byte)(end - start); 	//длина нового блока = end-start
			 return si;		 //возвращаем созданный блок 
			 }
	 }


	 private StringItem head; // назначение переменной

	//Конструктор по умолчанию
	public ListString()
	{
		head=null;		//Инициализация переменной head (пустая строка)
	}

	//конструктор для передаваемой строки
	public ListString(String string) {
		if(string.length()<=StringItem.SIZE) {		//проверяем длину строки
			head = new StringItem(string);		//если длина строки <=16, то создаем блок из всей строки и он становится головой
		return;
		}
		head=new StringItem(string.substring(0,StringItem.SIZE));		//иначе создаем головной блок из первый 16 символов полученной строки
		StringItem h=head;		//создаем переменную итератор для получения доступа к блокам списка
		int n = (string.length()/StringItem.SIZE);	//чтобы понять сколько блоков всего, делим количество символов строки на 16, пусть это число равно n
		for(int i=1; i<=n; i++) {		//эн раз создаем блок (StringItem(String string)) из символов строки начиная с конца предыдущего блока (с помощью открытого метода string.substring(i* StringItem.SIZE, Math.min((i+1)*StringItem.SIZE, string.length()))))
			h.next=new StringItem(string.substring(i* StringItem.SIZE, Math.min((i+1)*StringItem.SIZE, string.length())));
			h=h.next;
		}
	}

    //копирующий конструктор
	public ListString(ListString sourceItem) {			
		head=new StringItem(sourceItem.head);	//голова копии = копии головы полученного блока , для этого вызываем конструктор StringItem для копирования
		StringItem n1=head;
		StringItem n2=sourceItem.head.next;	//создаем два иттератора (1-указывает на голову копии, 2-на следующий за головой оригинала блок(на второй блок оригинального списка))
		while (n2!=null) {
			n1.next= new StringItem(n2);	//в цикле while перенсим блоки из оригинала в копию с помощью иттератора и копирующего конструктора StringItem до тех пор, пока, иттератор из полученного списка !=null
			n1=n1.next;
			n2=n2.next;
		}
	}

    //конструктор для блока
	public ListString (StringItem st) {			 
		head=st;
	}

	//копировать элементы одного массива в другой
	private static void copy(char [] finish, char[] start, int startCopy, int startPaste, int k) {
		for(int i=0; i<k; i++) {
			start[startPaste+i]=finish[startCopy+i];
		}
	}

    //возвращает реальную длину строки и объеденяет их (если это возможно)
	public int length() {			
		StringItem n1=head.next;	
		StringItem n2=head;			//создаем два иттератора, 1 указывает на следующий за головой блок, 2 указывает на голову
		int result=head.size;		//создаем переменную result = длине головы
		while(n1!=null){			//пока 2 иттератор не указывает на null
			result=result+n1.size;     //делаем:к перемнной resuln + длину блока иттератора 2
		if(n2.join()==false) 	//если блок иттератора 1 не может быть объединен  блоком иттератора 2 (проверяем с помощью метода join),то
			n2=n1;			//иттератор 2 = иттератору 1 
		n1=n1.next;		//иттератор 1 теперь указывает на следующий блок
		}
		return result;		//возвращаем result
	}

    //класс для хранения ссылки на блок и индекса конкретного символа внутри этого блока 
	private class Position {	
		private int i; 			//конкретный индекс 
		private StringItem s;	//ссылка на блок, в котором находится наш индекс
		public Position(int i,StringItem s) {		
			this.i=i;
			this.s=s;		//соотносит поля объекта с полученными данными
		}
	 }

    // Метод для определения Position
	 private Position search(int index) {
		if(index<=head.size){
			return new Position(index,null);//если индекс в пределах головы, то контейнер создается со значением этого индекса, а ссылка на блок это null
		}		 //созданный контейнер возвращается из метода
		StringItem n1=head;
		StringItem n2=n1;	//иначе делаем два иттератора(один указывает на голову, а другой на иттератор 1 )
		int i=0;						//делаем переменную i, котрая будет хранить длины блоков до индексированного 
		while (i+n1.size<=index) {	 //пока мы не дойдем до индексированного блока(i+длина блока иттератора 1 меньше или равно индекса)
		   n2=n1;		//делаем:иттератор 2 указывает на иттератор 1 (синхронизует иттераторы)
		   if(n1.next==null){
			   return new Position(-1,null);	//если следущий за блоком иттератора 1 блок =0, возвращаем из метода p с индексом -1 и ссылкой на блок null (когда индекс находится за пределами списка)
		   }
			i=i+n1.size;	//иначе увеличиваем переменную i на длину блока иттератора 1 
			n1=n1.next;	//иттератор 1 указывает на следующий блок
		}
		return new Position(index-i,n2);//возвращаем локальный индекс символа внутри блока и ссылку на предыдущий блок
	}


	// возвращает последний блок списка
	private StringItem last () {
		StringItem n1=head;
		StringItem n2=head;		//делаем два иттератора, оба указывают на голову
		while(n1!=null){	//пока иттератор 1 не указывает на 0, делаем:
			n2=n1;			//иттератор 2 = иттератор 1
			n1=n1.next;		//иттератор 1 = следующему блоку
		}
		
		return n2;	//возвращаем иттератор 2
	}


	//возвращает число по заданному индексу
	public char charAt(int index) {
		index=index-1;		//так как индексы записываем с 1, а в java с 0, то мы уменьшаем полученный индекс на еденицу
		if(index<0) {	//проверяем корректен ли индекс:он должен быть больше 0 и меньше длины строки
			throw new ListStringException("Нет такой позиции");		//иначе выбрасываем исключенние
			}	
		Position p = search(index);	//иначе через меетод indexp(создает контейнер хранящий локальный индекс в блоке и ссылку на предыдущий блок)
		if(p.i ==-1 && p.s == null)
			throw new ListStringException("Нет такой позиции");		//иначе выбрасываем исключенние
		if(index<StringItem.SIZE)		//вернуть символ по индексу если индекс меньше 16, то просто возвращаем символ из головного блока
			return head.symbols[p.i];
		return p.s.next.symbols[p.i];
	}



	//Заменить в строке символ в позиции index на символ ch
	public void setCharAt(int index, char ch)
	{
		index=index-1;		//так как индексы записываем с 1, а в java с 0, то мы уменьшаем полученный индекс на еденицу
		if(index<0) {	//проверяем корректен ли индекс:он должен быть больше 0 и меньше длины строки
			throw new ListStringException("Нет такой позиции");		//иначе выбрасываем исключенние
			}	
		Position p= search(index);	//иначе через меетод indexp(создает контейнер хранящий локальный индекс в блоке и ссылку на предыдущий блок)
		if(p.i==-1 && p.s==null)
			throw new ListStringException("Нет такой позиции");		//иначе выбрасываем исключенние
		if(p.s == null) {		//вернуть символ по индексу если индекс меньше 16, то просто возвращаем символ из головного блока
			head.symbols[p.i]=ch;
			return;
		}
		//System.out.println(p.s.symbols[0]);
		p.s.next.symbols[p.i]=ch;			//Если позиция действительна заменить символ на ch
	}


	//добавляют в конец соответсвующий элемент
	public void append(ListString st) {
		if(head==null) {				// если голова=0, то голова = голове списка полученого из строки 
			head=st.head;
		}
		else
			last().next=st.head;	//иначе получаем доступ к последнему элементу (с помощью метода last) и его следующий элемент становится = голове списка полученого из строки 
	}


	//добавляют в конец соответсвующий элемент
	public void append(String string) {
		ListString st=new ListString(string);
		if(head==null)				// если голова=0, то голова = голове списка полученого из строки 
			head=st.head;
		else
			last().next=st.head;	//иначе получаем доступ к последнему элементу (с помощью метода last) и его следующий элемент становится = голове списка полученого из строки 
	}


	//добавляют в конец соответсвующий элемент
	public void append(char d) {
		if(head==null)		//проверяем размерность строки и не пустая ли она
			return;		//если пустая, то возвращаем
		StringItem h = last();
		if(h.size < StringItem.SIZE) {		//если в последнем StringItem есть место, то добавлем символы туда
			h.symbols[h.size]=d ;
			h.size++;
		}
		else {	//иначе создаем новый блок в который помещаем эти символы и привязываем его к концу списка
			StringItem h2 = new StringItem();
			h2.symbols[0] = d;
			h.next=h2;
		}
	}

    // Вспомогательный метод для вставки
	private void insertR(Position p, ListString string) {
		StringItem save=string.last();	//сохранить в отдельную переменную(save) конец полученного списка
		if(p.i==0 && p.s==null){	//1.в начало списка: если индекс из контейнера =0 и ссылка внутри контейнера =0:
			save.next=head;		//следующий за save блок = head 
			head=string.head;		//head = голова полученного списка
			return;		
		}
		if(p.i==0 && p.s!=null) {		//2.между блоками:если индекс=0 и ссылка внутри контейнера !=0:
			save.next=p.s.next;		//следующий за save блок = item.next
			p.s.next=string.head;		//голова полученного списка становится следующим блоком для peiner.item
			return;		
		}
		if(p.i>0 && p.s==null){			//3.в голову: если ссылка =0 и индекс больше 0
			head.divide(p.i);			//делим голову (метод divide)
			save.next=head.next;	//следующий за save блок = следующий за головой блок
			head.next=string.head;		//голова полученного списка становится следующим блоком после головы
			return;		
		}
											//4.в какое-то место, какого-то блока
			StringItem b1 = p.s.next.divide(p.i);	//делим индексированный блок (метод divide) доступ полчучаем через ссылку из p
		
			StringItem first=p.s.next;		//пересенная first-первый индексированный блок (после деления это символы инденксированного блока до индекса)
			first.next = b1;
			
			StringItem second=first.next;	//переменная second-следующий за first блок (после деления это символы инденксированного блока после индекса)
			save.next=second;		//следующий за save блок = second
			first.next=string.head;		//голова полученного списка становится следующим блоком для first
		
	}

    //вставка строки в список
	public void insert(int index, String string) {		
		if(head.size==0){		//если длина головы=0 
		ListString s= new ListString(string);	//то мы делаем из полученой строки список помещаем ссылку на него в переменную 
		head=s.head;	//и его голову помещаем в голову текущего списка(голова текущего списка ссылается на голову только что созданного)
		return;		//return
		}
		index=index-1;		//отнимаем от индекса еденицу(потому что в java с нуля)
		//проверяем корректен ли наш индекс:
		if(index<0)
			throw new ListStringException("Нет такой позиции");	 //должен быть больше 0, иначе исключение
		Position p=search(index);	//делаем p
		if(p.s==null && p.i==-1)	//если ссылка в контейнере на блок равна 0 и индекс равен -1 выбрасываем исключение
			throw new ListStringException("Нет такой позиции");
		if((p.s!=null && p.i==p.s.next.size) || (p.s==null && head.next==null && p.i==head.size)) {	//если (ссылка на блок не null и индекс =size индексированного блока (концу блока)) или (ссылка на блок = null и ссылка на следующий блок головы=0 и индекс=size головы), то
			append(string);	//вызываем метод append (string)
			return;
		}
		insertR(p, new ListString(string));		
	}
	
    
    //вставка строки в список
	public void insert(int index, ListString string) {		
		if(head.size==0){		//если длина головы=0 
		ListString s= new ListString(string);	//то мы делаем из полученой строки список помещаем ссылку на него в переменную 
		head=s.head;	//и его голову помещаем в голову текущего списка(голова текущего списка ссылается на голову только что созданного)
		return;		//return
		}
		index=index-1;	//отнимаем от индекса еденицу(потому что в java с нуля)
		//проверяем корректен ли наш индекс:
		if(index<0)
			throw new ListStringException("Нет такой позиции");	 //должен быть больше 0, иначе исключение
		Position p=search(index);	//делаем p
		if(p.s==null && p.i==-1)	//если ссылка в контейнере на блок равна 0 и индекс равен -1 выбрасываем исключение
			throw new ListStringException("Нет такой позиции");
		if((p.s!=null && p.i==p.s.next.size) || (p.s==null && head.next==null && p.i==head.size)) {	//если (ссылка на блок не null и индекс =size индексированного блока (концу блока)) или (ссылка на блок = null и ссылка на следующий блок головы=0 и индекс=size головы), то
			append(new ListString(string));		//вызываем метод append (string)
			return;
		}
		insertR(p, new ListString(string));	
	}

	

    //выделение подстроки
	public ListString substring(int start, int end) {	
		if(head==null)
			throw new ListStringException("Строка пустая");	//проверяем не пустая ли строка, если пустая то выбрасываем исключение
		start--;	//вычитаем из start и end 1
		end--;
		if(start<0||end<0)
			throw new ListStringException("Введены некорректные данные");//проверяем корректность 
		Position s = search(start);	//делаем p, если из контейнера start индекс=-1 и ссылка на предыдущий блок=0, то выбрасываем исключение
		if(s.i==-1 && s.s==null)
			throw new ListStringException("Введены некорректные данные");
		Position e = search(end);
		StringItem startItem;
		StringItem endItem;		//делаем 2 переменные startItem и endItem-ссылки на начальный и конечный блоки
		if(s.s == null)		//если ссылка из контейнера start=0:
			startItem=head;//startItem=голове, инчае
		else
			startItem=s.s.next;		//startItem указывает на следующий за блоком из контейнера start блок
		if(e.i==-1 && e.s==null) {	//если индекс -1, а ссылка на блок=0:
			endItem=last();			//endItem указывает на последний из списка блок(метод Last)
			e.i=endItem.size;	//end внутри end p = длине последнего блока
		}
		else if(e.s==null) {
			endItem=head;	//если end находятся в голове (ссылка =0), endItem указывает на голову, иначе
		}
		else
			endItem=e.s.next;		//endItem указывает на следующий за блоком из контейнера end блок
		if(startItem==endItem)	//если start и end находятся в одном блоке (startItem = endItem), 
			return new ListString(startItem.subblok(s.i,e.i));	//с помощью subblok()
		ListString result= new ListString(startItem.subblok(s.i,startItem.size));  //делаем ListString из подстроки для блока, где находится start от стартовой позиции до конца блока
		StringItem n1=startItem.next; 
		StringItem n2=result.head;			//делаем два иттератора для изначального списка и для нового
		while(n1!=endItem) {		//пока иттератор изначального списка != конечному блоку делаем:
			n2.next=new StringItem(n1);//следующий за иттератором нового списка блок = копии иттератора изначального списка
			n1=n1.next;
			n2=n2.next;		//иттераторы делают шаг вперед
		}
		n2.next = endItem.subblok(0, e.i);	//следующий блок для иттератора нового списка это подстрока конечного блока от начала и до конечного индекса
		return result;	//возвращаем новый список
	}
	


	 public String toString() { 		//преобразует ListString в тип String
		StringItem n=head;			//делаем иттератор 
		int length=length();		//делаем переменную длины 
		char[] sym = new char[length];		//делаем пустой массив символов длины length
		int i=0;	//делаем переменную i=0
		while(n!=null){		//пока иттератор не указывает на 0
			copy(n.symbols, sym, 0, i, (int) n.size);	//копируем символы блока на который указывает иттератор в созданный массив, копируем с нулевой позиции, вставляем с позиции i (с помощью метода CopyArray)
			i=i+n.size; 		//i+=длина блока на который указывает иттератор
			n=n.next;	//иттератор указывает на следующий блок
		}
		return new String(sym);	//возвращаем массив символов преобразованный в строку с помощью конструктора String
	}

}


//класс исключения
 class ListStringException extends RuntimeException{		
    String ms;

	 public ListStringException(String ms) {
        this.ms = ms;		
	 }

     public String toString(){
        return ms;
     }
 }
