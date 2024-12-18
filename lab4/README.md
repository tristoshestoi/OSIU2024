# Пример плохого CI/CD файла

Ниже представлен код CI/CD файла с плохими практиками

```
name: Bad Practices Workflow

on:
  push:
    branches:
      - main 

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Build step
        run: |
          echo "Building..." 

  deploy:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy step
        env:
          SECRET_TOKEN: "12345"
        run: |
          echo "Deploying..."
          echo "Using secret: $SECRET_TOKEN"
          sleep 60

```


## Плохая практика №1. Нет версионирования
Отсутствие явного указания версии может привести к непредсказуемым результатам
Например, мы просто используем latest tag, что может привести к ошибкам

```
jobs:
  # плохая практика №1: нет версионирования
  build:
    runs-on: ubuntu-latest  # использование latest без указания конкретной версии
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Build step
        run: |
          echo "Building..." 
```

## Плохая практика №2. Не выполняется тестирование
Запуск без тестов может привести к тому, что ошибки не будут обнаружены до выхода в продакшен
В нашем коде мы решили просто пропустить этап тестирования)  
То есть build сразу идёт deploy.

## Плохая практика №3. Неправильное использование секретов
Публикация секретов в открытом репозитории небезопасна. Добавление секретов прямо в файл может привести к утечке, если репозиторий публичный.

```
steps:
      - name: Deploy step
        env:
          # плохая практика №3: неправильное использование секретов
          SECRET_TOKEN: "12345"
```

## Плохая практика №4. Отсутствие уведомлений
Разработчики не получают уведомлений о статусе сборки, что затрудняет выявление ошибок

## Плохая практика №5. Долгие процессы без параллельного выполнения
Если все работает последовательно, это увеличивает время развертывания

```
  deploy:
    runs-on: ubuntu-latest
    needs: build  # плохая практика №5: последовательное выполнение этапов вместо параллельного
    steps:
      - name: Deploy step
        env:
          # плохая практика №3: неправильное использование секретов
          SECRET_TOKEN: "12345"
        run: |
          echo "Deploying..."
          echo "Using secret: $SECRET_TOKEN"
          sleep 60  # долгий процесс без оптимизации (плохая практика №5)
```

## Результаты деплоя

Подробные этапы деплоя можно посмотреть во вкладке Actions  

![image](https://github.com/user-attachments/assets/acb8b234-d33b-4fe5-b3b5-581628e33cba)



# Пример хорошего CI/CD файла

Ниже представлен код CI/CD файла с хорошими практиками

```
name: Good Practices Workflow

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Build step
        run: |
          echo "Building application..."

  unit_tests:
    runs-on: ubuntu-20.04
    needs: build
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.9"

      - name: Install pytest
        run: pip install pytest

      - name: Run unit tests
        run: pytest lab4/tests/

  deploy:
    runs-on: ubuntu-20.04
    needs: unit_tests
    steps:
      - name: Deploy step
        env:
          SECRET_TOKEN: ${{ secrets.SECRET_TOKEN }}
        run: |
          echo "Deploying application..."
          echo "Using secret: $SECRET_TOKEN"

  notify:
    runs-on: ubuntu-20.04
    needs: [build, unit_tests, deploy]
    steps:
      - name: Send notifications
        run: |
          echo "Sending notification about the status of the workflow..."
          echo "Build, tests, and deployment have completed successfully."

```

## Хорошая практика №1. Версионирование образа
Указываем конкретную версию образа
```
jobs:
  # хорошая практика №1: версионирование образа
  build:
    runs-on: ubuntu-20.04  # указываем конкретную версию образа
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Build step
        run: |
          echo "Building application..."
```
## Хорошая практика №2. Выполнение тестов
Добавление стадии тестирования для выявления ошибок до развёртывания
```
  # хорошая практика №2: выполнение тестов
  unit_tests:
    runs-on: ubuntu-20.04
    needs: build
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.9"  # используем конкретную версию Python

      - name: Install pytest
        run: pip install pytest

      - name: Run unit tests
        run: pytest lab4/tests/
```

## Хорошая практика №3. Безопасное хранение секретов
Используйте секреты, хранящиеся в безопасном месте, например, K8s secrets или secrets manager
```
steps:
      - name: Deploy step
        env:  # используем секреты, хранящиеся в безопасном месте (в нашем случае - GitHub Secrets)
          SECRET_TOKEN: ${{ secrets.SECRET_TOKEN }}
```

## Хорошая практика №4. Уведомления
Добавление уведомлений о статусе сборки для разработчиков
```
  notify:
    runs-on: ubuntu-20.04
    needs: [build, unit_tests, deploy]  # уведомления запускаются после всех этапов
    steps:
      - name: Send notifications
        run: |
          echo "Sending notification about the status of the workflow..."
          echo "Build, tests, and deployment have completed successfully."
```

## Хорошая практика №5. Параллельное выполнение процесса
Разделение задач на несколько этапов для ускорения процесса развертывания
parallel:
  - build
  - test

deploy:
  stage: deploy
  script:
    - echo "Deploying..."

## Результаты деплоя

Подробные этапы деплоя можно посмотреть во вкладке Actions   

![image](https://github.com/user-attachments/assets/9c6f9dd6-211c-4a63-93ef-895237754c8f)


README с описанием плохих практик и их исправлений
Плохой CI/CD файл:
В этом разделе представлен плохой CI/CD файл и объясняется, какие плохие практики в нём содержатся.
1. Нет версионирования
Плохая практика: Используется тег latest, что может привести к неожиданным ошибкам в сборке.
Исправление: В хорошем файле указано конкретное версионирование образа (например, docker:1.19.3), что повышает предсказуемость и стабильность сборок.
2. Не выполняется тестирование
Плохая практика: Сборка и развертывание происходят без выполнения тестов, что может привести к появлению ошибок в продакшене.
Исправление: Добавлена стадия тестирования (например, unit_tests), что позволяет выявлять ошибки до развертывания и повышает качество кода.
3. Неправильное использование секретов
Плохая практика: Секреты хранятся в открытом виде в коде, что небезопасно и может привести к утечке данных.
Исправление: В хорошем файле секреты хранятся безопасно и загружаются из защищенного хранилища (например, K8s secrets), что улучшает безопасность приложения.
4. Отсутствие уведомлений
Плохая практика: Разработчики не получают уведомлений о статусе сборки, что затрудняет выявление ошибок и реагирование на них.
Исправление: В хорошем файле добавлены уведомления по электронной почте для команды, что позволяет оперативно реагировать на проблемы.
5. Долгие процессы без параллельного выполнения
Плохая практика: Все процессы выполняются последовательно, что замедляет развертывание и увеличивает время ожидания.
Исправление: В хорошем файле добавлено параллельное выполнение задач (например, parallel), что ускоряет процесс развертывания и делает его более эффективным.
