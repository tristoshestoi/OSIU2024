# LAB2
## Плохие практики в Dockerfile

### Использование тега latest
- Использование `latest` может привести к неожиданному поведению. Образ может измениться при, к примеру, ежедневной сборке, приведя к ошибкам сборки или неправильной работе итогового продукта

**Фикс:**
- Использование конкретной версию (например, `ubuntu:20.04`)

### Запуск от рута
- Запуск приложений от root подвергает контейнер уязвимостям. Злоумышленник получивший доступ к запущенному контейнеру нанести гораздо более серьезный вред при наличии доступа к root юзеру.
- Запуск приложений от рута в целом не является хорошей практикой, не только в докерфайлах

**Фикс:**
- Создание и использование пользователя без прав root повышает безопасность, ограничивая разрешения приложения. 

### Использование нескольких команд RUN без необходимости
- Каждая вызов `RUN` создает новый слой в Докер образе, что приводит к большему размеру 


**Фикс:**
- Объединяя команды в одном операторе `RUN`, вы уменьшаете количество слоев в образе, что уменьшает  размер образа, улучшает эффективность сборки и  минимизирует количество обращений к кешу менеджера пакетов

## Плохие практики при работе с контейнерами

### Запуск контейнеров с флагом `--privileged`
- Предоставляет контейнеру доступ ко всем устройствам хоста, что может привести к серьезным проблемам с безопасностью.


### Неиспользование сетевых изоляторов
- Запуск контейнеров в одной сети без изоляции может привести к утечке данных между контейнерами.