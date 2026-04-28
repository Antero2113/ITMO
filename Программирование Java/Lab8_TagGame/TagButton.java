import javax.swing.*;
import java.awt.*;

class TagButton extends JButton {

    public TagButton(int value) {
        super(String.valueOf(value)); // super конструктор со значением value
        setPreferredSize(new Dimension(50, 50)); // Задаём размер кнопки с помощью объекта Dimension, ширина и высота 50 пикселей
        int t = getPreferredSize().height * 5 / 8; // Вычисление размера шрифта кнопки (5/8 от высоты кнопки)
        setFont(new Font("Arial", Font.PLAIN, t)); // Устанавливаем шрифт кнопки
        this.setBackground(Color.black);
        this.setForeground(Color.white);
        setFocusable(false); // Отключение возможности получения фокуса кнопкой
    }

}
