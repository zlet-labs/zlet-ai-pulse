# Zlet AI Pulse Roadmap

## v0.1.0 — MVP

Цель: получить рабочее полноценное Windows-приложение с главным dashboard и компактным tray companion view для лимитов основных AI coding-провайдеров.

### База

- [ ] Использовать проверенную Windows architecture/provider foundation Win-CodexBar под MIT без раннего destructive pruning.
- [ ] Сохранить attribution и third-party notices для реально используемого кода.
- [ ] Собрать Tauri 2 + React + Rust приложение под Windows.
- [ ] Добавить portable build.

### Провайдеры MVP

- [ ] Codex: 5h, weekly, отдельные reset time, credits where available.
- [ ] Antigravity: Gemini session/weekly + Claude/GPT session/weekly + provider-specific details.
- [ ] Claude Code: session/weekly.
- [ ] OpenCode / OpenCode Go: доступные usage/quota данные.

### Main app UI/UX

- [ ] Полноценное главное окно Zlet AI Pulse.
- [ ] Dashboard со всеми включёнными провайдерами.
- [ ] Отдельный reset для каждого quota window.
- [ ] Provider detail view без потери полезных метрик.
- [ ] Русский и английский языки.
- [ ] Понятные статусы: «Осталось», «Сброс через», «Не авторизован», «Источник недоступен».
- [ ] Переключатель «Осталось / Использовано».
- [ ] Ручное обновление.
- [ ] Время последнего успешного обновления.
- [ ] Нормальная работа при Windows scaling 100/125/150/175/200%.

### Tray

- [ ] Компактный tray panel вместо копирования текущего Win-CodexBar UI.
- [ ] Ключевые session/weekly значения и reset times.
- [ ] Команда «Открыть Zlet AI Pulse».
- [ ] Корректное открытие/фокусировка уже существующего main window.
- [ ] Настраиваемое закрытие main window в tray.

### Надёжность

- [ ] Provider timeout и graceful fallback.
- [ ] Последнее успешное значение при временной ошибке с пометкой stale.
- [ ] Не логировать cookies, OAuth tokens и API keys.
- [ ] Тесты parser/fetch logic для MVP-провайдеров.
- [ ] UI smoke-test main window/tray/settings на реальной Windows-сборке.
- [ ] Повторный запуск не создаёт независимые дубли приложения.

## v0.2.0 — Daily driver

- [ ] Threshold notifications: 50%, 25%, 10%.
- [ ] Компактный tray status: например `C 72 · A 31`.
- [ ] Автообнаружение установленных CLI.
- [ ] Простой onboarding первого запуска.
- [ ] Автозапуск с Windows.
- [ ] Installer + portable release.
- [ ] Проверка обновлений.
- [ ] Настройки поведения main window/tray.

## v0.3.0 — Smart AI usage monitor

- [ ] «Что закончится первым».
- [ ] Сравнение доступного ресурса между провайдерами.
- [ ] Простая рекомендация провайдера для следующей большой задачи.
- [ ] История использования без отправки данных на сервер.
- [ ] OpenRouter как дополнительный provider.
- [ ] Основа для cost/token/provider-health данных там, где они доступны.

## Не цель MVP

- Поддерживать десятки провайдеров только ради числа в README.
- Повторять весь UI Win-CodexBar.
- Делать tray единственным интерфейсом приложения.
- Добавлять сложную аналитику до того, как основной desktop UX станет действительно удобным.
- Хранить внешние credentials без необходимости.
