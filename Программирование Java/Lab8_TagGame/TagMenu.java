import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;

public class TagMenu extends JMenuBar {

    public TagMenu(JFrame frame, TagPanel panel) {

        JMenu file = new JMenu("File"); // Создание раздела "File"
        file.setMnemonic('F'); // Установка мнемоники "F"
        add(file); // Добавление раздела "File" в меню

        JMenuItem newgame = new JMenuItem("New"); // Создание элемента "New"
        newgame.setMnemonic('N'); // Установка мнемоники "N"
        newgame.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_N, InputEvent.CTRL_DOWN_MASK)); // Установка акселератора "Ctrl+N"
        newgame.addActionListener(new ActionListener() { // Добавление приёмника действий для элемента "New"
            public void actionPerformed(ActionEvent e) {
                panel.startNew();
            } // Вызов метода startNew() у объекта panel при активации элемента "New"
        });
        file.add(newgame); // Добавление элемента "New" в раздел "File"
        file.addSeparator(); // Добавление разделителя
        JMenuItem exit = new JMenuItem("Exit"); // Создание элемента "Exit"
        exit.setMnemonic('E'); // Установка мнемоники "E"
        exit.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_E, InputEvent.CTRL_DOWN_MASK)); // Установка акселератора "Ctrl+E"
        exit.addActionListener(new ActionListener() { // Добавление приёмника действий для элемента "Exit"
            public void actionPerformed(ActionEvent e) {
                System.exit(0);
            } // Завершение приложения при активации элемента "Exit"
        });
        file.add(exit); // Добавление элемента "Exit" в раздел "File"

        JMenu help = new JMenu("Help"); // Создание раздела "Help"
        help.setMnemonic('H'); // Установка мнемоники "H"
        add(help); // Добавление раздела "Help" в меню

        JMenuItem about = new JMenuItem("About"); // Создание элемента "About"
        about.setMnemonic('A'); // Установка мнемоники "A"
        about.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_A, InputEvent.CTRL_DOWN_MASK)); // Установка акселератора "Ctrl+A"
        about.addActionListener(new ActionListener() { // Добавление приёмника действий для элемента "About"
            public void actionPerformed(ActionEvent e) {
                JOptionPane.showMessageDialog(frame, "Карандашева Анастасия, P3168, 2023 год", "Кто выполнил", JOptionPane.INFORMATION_MESSAGE);
            } // Вывод модального диалогового окна с информацией о студенте при активации элемента "About"
        });
        help.add(about); // Добавление элемента "About" в раздел "Help"
    }

}
