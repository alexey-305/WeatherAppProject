# WeatherApp

iOS приложение для просмотра прогноза погоды.

## Настройка перед запуском

Проект использует OpenWeatherMap API. Ключ хранится локально и не включён в репозиторий.

### 1. Получите API ключ

Зарегистрируйтесь на [openweathermap.org](https://openweathermap.org) и получите бесплатный API ключ.

### 2. Создайте Secrets.plist

Создайте файл `Secrets.plist` в папке `WeatherAppProject/` со следующим содержимым:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>OpenWeatherAPIKey</key>
    <string>ВАШ_API_КЛЮЧ_ЗДЕСЬ</string>
</dict>
</plist>
```

### 3. Добавьте файл в Xcode

В Xcode: правой кнопкой на папку WeatherAppProject → Add Files → выберите Secrets.plist → убедитесь что стоит галочка Target: WeatherAppProject.

## Архитектура

- **UIKit** без Storyboard, верстка в коде
- **CoreData** для кэширования погоды и хранения городов
- **OpenWeatherMap API** для данных о погоде и геокодинга
- **WidgetKit** для виджета на главном экране
- **Coordinator** паттерн для навигации

## Экраны

- Онбординг — запрос геолокации
- Главный экран — текущая погода, слайдер городов (UIPageViewController)
- Прогноз на 24 часа
- Дневная сводка
- Настройки
