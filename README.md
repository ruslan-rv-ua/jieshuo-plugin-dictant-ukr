This is a plugin for the Jieshuo screen reader, an Android screen reading program for visually impaired. 
The plugin is compatible only with the Ukrainian language, so the further description will be in Ukrainian.

# "Диктант" — плагін Jieshuo для зручного надиктовування тексту

Встановіть фокус на поле редагування та активуйте плагін. Почуєте відповідний звуковий сигнал і вібрацію. 
Починайте диктувати. Після закінчення знову почуєте звуковий сигнал.

Якщо фокус скрінрідера не на полі редагування, ви почуєте "не в редакторі," і плагін припинить роботу.

## Очистити редактор

Щоб видалити текст із поля редагування, просто скажіть "диктант" на початку голосового набору. 

- якщо передумали і хочете надиктувати усе наново
- якщо в полі редагування є "плейсхолдер" — текст, що надає вам підказку, що саме потрібно вводити, наприклад, "Пошук."

## Крок за кроком

Текст можна надиктовувати у кілька кроків: активували плагін, надиктували, активували плагін, надиктували, і так далі. При цьому кожен новий надиктований текст буде додаватись до редактора, а весь текст редактора буде відформатовано з урахуванням знаків пунктуації. 

Приклад:

1. Надиктували 
    ```
    зараз
    ```
    У редакторі з'явиться:
    ```
    зараз
    ```
1. З'ясували, яка зараз погода за вікном і надиктували 
    ```
    сонячно
    ```
    У редакторі з'явиться
    ```
    зараз сонячно
    ```
1. Згадали що треба закінчити речення, надиктували
    ```
    крапка
    ```
    У редакторі відобразиться
    ```
    Зараз сонячно.
    ```
    тобто речення з великої літери, з крапкою на кінці.
1. Згадали що забули вказати, де саме зараз сонячно. 
Треба надиктувати усе наново. Диктуємо
    ```
    диктант зараз у селі з великої великі з великої плоскогубці сонячно знак оклику
    ```
    У редакторі з'явиться
    ```
    Зараз у селі Великі Плоскогубці сонячно!
    ```

## Керування диктантом

Плагін розпізнає наступні знаки пунктуації:

- двокрапка
- крапка
- кома
- ліва дужка
- права дужка
- тире
- знак оклику
- знак питання

Команди:

- диктант — видалити усе з редактора
- абзац — подальший текст буде у новому рядку
- з великої — наступне слово буде з великої букви
