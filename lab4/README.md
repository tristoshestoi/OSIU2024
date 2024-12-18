# Пример плохого CI/CD файла

Ниже представлен код CI/CD файла с плохими практиками:

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
Отсутствие явного указания версии может привести к непредсказуемым результатам. Например, мы просто используем latest tag, что может привести к ошибкам.

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
Запуск без тестов может привести к тому, что ошибки не будут обнаружены до выхода в продакшен. В нашем коде мы решили просто пропустить этап тестирования)  
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
Разработчики не получают уведомлений о статусе сборки, что затрудняет выявление ошибок.

## Плохая практика №5. Долгие процессы без параллельного выполнения
Если все работает последовательно, это увеличивает время развертывания.

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

Подробные этапы деплоя можно посмотреть во вкладке Actions.  

![image](https://github.com/user-attachments/assets/acb8b234-d33b-4fe5-b3b5-581628e33cba)



# Пример хорошего CI/CD файла

Ниже представлен код CI/CD файла с хорошими практиками:

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
          echo "Build complete!"

  unit_tests:
    runs-on: ubuntu-20.04
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
        run: pytest lab4/tests

  deploy:
    runs-on: ubuntu-20.04
    needs: [build]
    steps:
      - name: Deploy step
        env:
          SECRET_TOKEN: ${{ secrets.SECRET_TOKEN }}
        run: |
          echo "Deploying application..."
          echo "Using secret: $SECRET_TOKEN"

  notify_build:
    runs-on: ubuntu-20.04
    needs: [build]
    steps:
      - name: Notify build complete
        run: echo "Build completed successfully!"

  notify_tests:
    runs-on: ubuntu-20.04
    needs: [unit_tests]
    steps:
      - name: Notify tests complete
        run: echo "Tests completed successfully!"

  notify_deploy:
    runs-on: ubuntu-20.04
    needs: [deploy]
    steps:
      - name: Notify deploy complete
        run: echo "Deploy completed successfully!"


```

## Хорошая практика №1. Версионирование образа
Указываем конкретную версию образа.
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
Добавление стадии тестирования для выявления ошибок до развёртывания. Был создан файлик с гарантировано верными тестами для pytest (а-ля 2+2 = 4).
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
Используйте секреты, хранящиеся в безопасном месте. Использовали github secrets.
```
steps:
      - name: Deploy step
        env:  # используем секреты, хранящиеся в безопасном месте (в нашем случае - GitHub Secrets)
          SECRET_TOKEN: ${{ secrets.SECRET_TOKEN }}
        run: |
          echo "Deploying application..."
          echo "Using secret: $SECRET_TOKEN"
```

![image](https://github.com/user-attachments/assets/a5d5e7c8-6146-4e85-aed2-854bc7e0f0da)


## Хорошая практика №4. Уведомления
Добавление уведомлений о статусе сборки для разработчиков. Обычно добавляется, например, через Slack, Email или Telegram, но для демонстрации достаточно и обычного echo.
```
  notify_build:
    runs-on: ubuntu-20.04
    needs: [build]
    steps:
      - name: Notify build complete
        run: echo "Build completed successfully!"

  notify_tests:
    runs-on: ubuntu-20.04
    needs: [unit_tests]
    steps:
      - name: Notify tests complete
        run: echo "Tests completed successfully!"

  notify_deploy:
    runs-on: ubuntu-20.04
    needs: [deploy]
    steps:
      - name: Notify deploy complete
        run: echo "Deploy completed successfully!"
```

## Хорошая практика №5. Параллельное выполнение процесса
Разделение задач на несколько этапов для ускорения процесса развертывания. Уведомления (notify_build, notify_tests, notify_deploy) выполняются параллельно с другими этапами, а не после всех этапов.
То есть deploy, notify_build, notify_tests, и notify_deploy могут запускаться одновременно, если их зависимости выполнены. Это хорошо видно в Summary после пуша (скриншот ниже).

```
  deploy:
    runs-on: ubuntu-20.04
    needs: [build]
    steps:
      - name: Deploy step
        env:
          SECRET_TOKEN: ${{ secrets.SECRET_TOKEN }}
        run: |
          echo "Deploying application..."
          echo "Using secret: $SECRET_TOKEN"

  notify_build:
    runs-on: ubuntu-20.04
    needs: [build]
    steps:
      - name: Notify build complete
        run: echo "Build completed successfully!"

  notify_tests:
    runs-on: ubuntu-20.04
    needs: [unit_tests]
    steps:
      - name: Notify tests complete
        run: echo "Tests completed successfully!"

  notify_deploy:
    runs-on: ubuntu-20.04
    needs: [deploy]
    steps:
      - name: Notify deploy complete
        run: echo "Deploy completed successfully!"

```

## Результаты деплоя

Подробные этапы деплоя можно посмотреть во вкладке Actions   

![image](https://github.com/user-attachments/assets/08b94d32-13e9-46e8-98b1-4f92984918cd)


## Выводы

В данной работе была проведена работа с CI/CD - были рассмотрены 5 "плохих практик", которые может и запускаются нормально, но на дальней дистанции могут в разы усложнить разработку. Далее эти практики были исправлены на более предпочтительные и универсальные - начиная с тестов и заканчивая паралелльной отпарвкой уведомлений о завершении этапов тестирования, билда и деплоя. Все эти изменения были направлены на то, чтобы минимизировать риски и повысить производительность. Как мне кажется, вышло неплохо!
