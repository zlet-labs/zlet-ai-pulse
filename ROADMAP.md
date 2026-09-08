# Zlet Limits Roadmap

## v0.1.0 — MVP

Цель: получить рабочее Windows-приложение в системном трее с понятным отображением лимитов основных AI coding-провайдеров.

### База

- [ ] Перенести минимально необходимую архитектуру из Win-CodexBar под MIT.
- [ ] Сохранить attribution и third-party notices для перенесённого кода.
- [ ] Собрать Tauri 2 + React + Rust приложение под Windows.
- [ ] Добавить portable build.

### Провайдеры MVP

- [ ] Codex: 5h, weekly, reset time, credits where available.
- [ ] Antigravity: Gemini session/weekly + Claude/GPT session/weekly.
- [ ] Claude Code: session/weekly.
- [ ] OpenCode / OpenCode Go: доступные usage/quota данные.

### UI/UX

- [ ] Новый компактный tray panel вместо копирования текущего Win-CodexBar UI.
- [ ] Русский и английский языки.
- [ ] Понятные статусы: «Осталось», «Сброс через», «Не авторизован», «Источник недоступен».
- [ ] Переключатель «Осталось / Использовано».
- [ ] Ручное обновление.
- [ ] Время последнего успешного обновления.
- [ ] Нормальная работа при Windows scaling 100/125/150/175/200%.

### Надёжность

- [ ] Provider timeout и graceful fallback.
- [ ] Последнее успешное значение при временной ошибке с пометкой stale.
- [ ] Не логировать cookies, OAuth tokens и API keys.
- [ ] Тесты parser/fetch logic для MVP-провайдеров.
- [ ] UI smoke-test tray/settings на реальной Windows-сборке.

## v0.2.0 — Daily driver

- [ ] Threshold notifications: 50%, 25%, 10%.
- [ ] Компактный tray status: например `C 72 · A 31`.
- [ ] Автообнаружение установленных CLI.
- [ ] Простой onboarding первого запуска.
- [ ] Автозапуск с Windows.
- [ ] Installer + portable release.
- [ ] Проверка обновлений.

## v0.3.0 — Smart quota manager

- [ ] «Что закончится первым».
- [ ] Сравнение доступного ресурса между провайдерами.
- [ ] Простая рекомендация провайдера для следующей большой задачи.
- [ ] История использования без отправки данных на сервер.
- [ ] OpenRouter как дополнительный provider.

## Не цель MVP

- Поддерживать десятки провайдеров только ради числа в README.
- Повторять весь функционал Win-CodexBar.
- Добавлять сложную аналитику до того, как основной tray UX станет действительно удобным.
- Хранить внешние credentials без необходимости.
