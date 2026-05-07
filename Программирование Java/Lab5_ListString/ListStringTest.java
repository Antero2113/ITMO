public class ListStringTest {
	public static void main (String[] args ) {
		ListString stroke = new ListString ("01234567890123456789012345678901234567890123456789");
		System.out.println(stroke);
        System.out.println(stroke.length());
		stroke.insert(16, "[ВСТАВКА]");
		System.out.println(stroke);
		ListString stroke2 = stroke.substring(1, 100);
		System.out.println(stroke);
		stroke2.append(stroke);
		System.out.println(stroke2);
		
	}
}
