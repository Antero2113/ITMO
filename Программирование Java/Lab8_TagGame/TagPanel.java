import javax.swing.*;
import java.awt.*;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.util.Random;

public class TagPanel extends JPanel {
    private int placeEmpty; // индекс пустой кнопки
    private int size = 4; // размер поля
    private TagButton[][] buttons; // массив кнопок
    private int[] buttonNumbers; // массив значений кнопок

    public TagPanel() {
        super(new GridLayout(4, 4)); // создание легковесного контейнера на основе сетки 4*4
        buttons = new TagButton[size][size]; // Создаем двумерный массив кнопок размером size x size
        buttonNumbers = new int[16]; // Создаем массив значений кнопок размером 16
        for (int i = 0; i < 16; i++) // Заполняем массив значениями от 0 до 15
            buttonNumbers[i] = i;
        initButtons(); // добавление кнопок на контейнер (поле)
    }

    private void initButtons() {
        for (int i = 0; i < 16; i++) { // Перемешиваем значения в массиве случайным образом
            int n = new Random().nextInt(15);
            int saved = buttonNumbers[i]; // Временно сохраняем значение на позиции i
            buttonNumbers[i] = buttonNumbers[n]; // Заменяем значение на позиции i случайным значением
            buttonNumbers[n] = saved; // Заменяем случайное значение на позиции n сохраненным значением
        }
        for (int i = 0; i < 16; i++) { // Заполняем массив кнопок и добавляем их на контейнер
            int x = i / size; // Вычисляем индекс строки
            int y = i % size; // Вычисляем индекс столбца
            buttons[x][y] = new TagButton(buttonNumbers[i]); // Создаем кнопку с соответствующим значением
            buttons[x][y].addActionListener(e -> { // Добавляем обработчик событий для клика по кнопке
                replaceEmpty(x, y); // Перемещаем кнопку при клике
            });

            if (buttonNumbers[i] == 0) { // Если значение кнопки равно 0, скрываем кнопку
                placeEmpty = i; // Запоминаем индекс пустой кнопки
                buttons[x][y].setVisible(false); // Скрываем пустую кнопку
            }

            add(buttons[x][y]); // Добавляем кнопку на контейнер
        }

        replace(3, 3); // Меняем местами первую и последнюю кнопки


        addKeyListener(new KeyAdapter() { // Добавляем обработчик событий клавиатуры
            @Override
            public void keyPressed(KeyEvent e) { // При нажатии клавиши
                int x = placeEmpty / size; // Вычисляем индекс строки пустой кнопки
                int y = placeEmpty % size; // Вычисляем индекс столбца пустой кнопки
                if (e.getKeyCode() == KeyEvent.VK_LEFT) {
                    replaceEmpty(x, y + 1); // Перемещаем кнопку влево
                }
                if (e.getKeyCode() == KeyEvent.VK_RIGHT) {
                    replaceEmpty(x, y - 1); // Перемещаем кнопку вправо
                }
                if (e.getKeyCode() == KeyEvent.VK_UP) {
                    replaceEmpty(x + 1, y); // Перемещаем кнопку вверх
                }
                if (e.getKeyCode() == KeyEvent.VK_DOWN) {
                    replaceEmpty(x - 1, y); // Перемещаем кнопку вниз
                }
                if (e.getKeyCode() == KeyEvent.VK_W) {// Для проверки победы
                    win();
                }
            }
        });
        setFocusable(true); // Устанавливаем фокус на контейнер
    }
    
    // Новая игра
    public void startNew() {
        for (int i = 0; i<16; i++) { // перемешивание значений
            int n = new Random().nextInt(15);
            int hold = buttonNumbers[i]; // промежуточная переменная для хранения адреса i значения
            buttonNumbers[i] = buttonNumbers[n];
            buttonNumbers[n] = hold;
        }
        for (int i=0; i<16; i++) { // распределить значения в кнопки
            int str = i/4; // индекс строки
            int stlb = i%4; // индекс столбца
            buttons[str][stlb].setText(String.valueOf(buttonNumbers[i])); // устанавливаем текст на кнопке равным значению
            buttons[str][stlb].setVisible(true); // делаем кнопку видимой
            if (buttonNumbers[i] == 0) { // если значение равно 0, то прячем кнопку
                placeEmpty = i; // задаём индекс пустой кнопки
                buttons[str][stlb].setVisible(false); // делаем пустую кнопку невидимой
            }
        }
        replace(3,3); // поменять местами первую и последнюю кнопки
    }

    private void replace(int x0, int y0) {
        int x = placeEmpty / size; // индекс строки пустой кнопки
        int y = placeEmpty % size; // индекс столбца пустой кнопки
        buttons[x][y].setText(buttons[x0][y0].getText()); // пустая кнопка получает текст перемещаемой
        buttons[x0][y0].setText("0"); // перемещаемая получает текст "0"
        buttons[x][y].setVisible(true); // меняем видимость кнопок
        buttons[x0][y0].setVisible(false);
        placeEmpty = (x0 * size) + y0; // новый индекс пустой кнопки
    }

    private void replaceEmpty(int x0, int y0) {
        boolean validCoordinates = (x0 >= 0 && x0 < size) && (y0 >= 0 && y0 < size); // проверка, что координаты не за пределами поля

        if (!validCoordinates) {
            return; // выход из функции, если координаты недопустимы
        }

        int x = placeEmpty / size; // индекс строки пустой кнопки
        int y = placeEmpty % size; // индекс столбца пустой кнопки
        int distanceToX = Math.abs(x0 - x); // расстояние между кнопкой и пустой кнопкой по горизонтали
        int distanceToY = Math.abs(y0 - y); // расстояние между кнопкой и пустой кнопкой по вертикали
        boolean sameRow = (x0 == x); // кнопки находятся в одной строке
        boolean sameColumn = (y0 == y); // кнопки находятся в одном столбце

        if ((distanceToX == 1 && sameColumn) || (distanceToY == 1 && sameRow)) { // кнопки находятся рядом друг с другом
            replace(x0, y0); // меняем местами кнопки
        }

        if (check()) {
            JOptionPane.showMessageDialog(null, "Поздравляем! Вы прошли игру!", "Победа", JOptionPane.INFORMATION_MESSAGE);
        }
    }

    private boolean check() {
        for (int i = 0; i < 15; i++) { // проход по всем кнопкам
            int x = i / size; // индекс строки кнопки
            int y = i % size; // индекс столбца кнопки
            String buttonText = buttons[x][y].getText(); // значение кнопки
            String buttonOrder = String.valueOf(i + 1); // значение её порядкового номера
            if (!buttonText.equals(buttonOrder)) return false;
        }
        return buttons[3][3].getText().equals("0"); // возвращаем, является ли последняя кнопка нулевой (пустой)
    }

    private void win() {
        for (int index = 0; index < (size * size) - 1; index++) { // Перебор по всем кнопкам кроме последней
            int i = index / size; // Вычисление индекса строки
            int j = index % size; // Вычисление индекса столбца
            buttons[i][j].setText(String.valueOf(index + 1)); // Установка текста кнопки в порядковый номер
            buttons[i][j].setVisible(true); // Установка видимости кнопки
        }
        buttons[size - 1][size - 1].setText(String.valueOf(0)); // Установка текста последней кнопки в 0
        buttons[size - 1][size - 1].setVisible(false); // Скрытие последней кнопки
        placeEmpty = 15; // Установка индекса пустой кнопки на последнюю

        setFocusable(true); // Установка фокуса на панель
    }

}