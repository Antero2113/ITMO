import javax.swing.*;
import java.awt.*;

public class TagFrame extends JFrame {

    public TagFrame() {
        super("Пятнашки"); // инициализация окна
        TagPanel tagPanel = new TagPanel();
        TagMenu tagMenu = new TagMenu(this, tagPanel);

        add(tagPanel); // добавить панель на окно
        setJMenuBar(tagMenu); // добавить меню на окно

        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE); // операция при закрытии окна
        setSize(400, 400); // размер окна

        setLocationRelativeTo(null); // по центру экрана
        setResizable(false); // отключить масштабируемость
        setVisible(true); // сделать видимым
    }
}
