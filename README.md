# Zapret для Megafon / NetByNet / WIFIRE — исправление YouTube

Решение проблемы, когда **YouTube не открывается ни на одной стандартной стратегии** zapret-discord-youtube (FAKE TLS, ALT, SIMPLE FAKE и др.).

Связанный репорт: **[Issue #15479](https://github.com/Flowseal/zapret-discord-youtube/issues/15479)** — *«не работает YouTube во всех конфигах»*, тесты показывают `YouTubeWeb HTTP:SSL TLS1.2:SSL TLS1.3:SSL | Ping: Timeout`.

Основано на [Flowseal/zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube) и [bol-van/zapret](https://github.com/bol-van/zapret).

---

## В чём проблема

На провайдерах **Megafon**, **NetByNet** и **WIFIRE** (роутеры D-Link и аналоги) часто одновременно:

| Симптом | Причина |
|--------|---------|
| `youtube.com` / `www.youtube.com` не резолвятся (NXDOMAIN) | **DNS-подмена на роутере** (`192.168.0.1`) |
| Discord работает с zapret | Блокировка на уровне DPI, не DNS |
| YouTube не работает даже с zapret | Без рабочего DNS zapret **не может помочь** — домен не резолвится |
| Тесты zapret: YouTube — Timeout | Следствие сломанного DNS, а не «не та стратегия» |

Zapret обходит DPI, но **не чинит DNS**. Нужна связка: **DNS → hosts → стратегия**.

---

## Быстрый старт

### 1. Подготовка

1. Скачайте [последний релиз zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube/releases/latest).
2. Скопируйте файлы из **этого репозитория** поверх распакованной папки (или используйте эту папку целиком, если в ней уже есть `bin\` из релиза).
3. Распакуйте в путь **без кириллицы и пробелов**, например: `C:\zapret\`
4. В свойствах архива/папки нажмите **«Разблокировать»** (если есть).
5. В браузере включите **Secure DNS (DoH)**: `https://dns.google/dns-query`

### 2. Одна кнопка — YouTube + Discord

Запустите **от имени администратора**:

```
setup-megafon.bat
```

Скрипт по порядку:

1. Выставит DNS `8.8.8.8` / `1.1.1.1`
2. Добавит записи YouTube в `hosts`
3. Запустит стратегию `general (MEGAFON).bat`

### 3. Проверка

- Откройте [youtube.com](https://www.youtube.com)
- Откройте Discord (приложение или браузер)

---

## Файлы

| Файл | Назначение |
|------|------------|
| **`setup-megafon.bat`** | Рекомендуется. DNS + hosts + zapret одним скриптом |
| **`general (MEGAFON).bat`** | Только zapret (если DNS и hosts уже настроены) |
| **`general Megafon.bat`** | То же, имя без скобок (удобнее двойной клик) |
| **`setup-dns-megafon.bat`** | Только DNS `8.8.8.8` / `1.1.1.1` |
| **`setup-youtube-hosts.bat`** | Только записи YouTube в `hosts` |
| **`service.bat`** | Менеджер службы, диагностика, автозапуск |

### Списки доменов и IP

| Файл | Назначение |
|------|------------|
| `lists/list-google.txt` | Домены Google/YouTube для DPI-обхода |
| `lists/ipset-exclude-google.txt` | Исключение Google IP из общего ipset |

---

## Устранение неполадок

### YouTube всё ещё не открывается

1. Запустите `setup-dns-megafon.bat` и `setup-youtube-hosts.bat` **от администратора** ещё раз.
2. В PowerShell проверьте DNS:
   ```powershell
   Resolve-DnsName youtube.com -Type A
   ```
   Должен вернуться IP, не ошибка.
3. Убедитесь, что в трее есть процесс **`winws.exe`** (иконка замка).
4. В `service.bat` → **Game Filter: disabled**, **IPSet Filter: none**.

### `Access is denied` / winws code 5

WinDivert не получил права на драйвер:

1. Запускайте bat **от администратора** (UAC).
2. Закройте другие экземпляры zapret / GoodbyeDPI / VPN.
3. `service.bat` → **Remove Services** → перезагрузка ПК → запуск снова.

### `'--filter-udp' is not recognized`

Командная строка слишком длинная (часто при установке в папку с **кириллицей** в пути). Перенесите zapret в `C:\zapret\`.

### Антивирус

Добавьте папку zapret в **исключения**. WinDivert — легитимный драйвер фильтрации трафика, не вирус.

---

## Структура проекта

```
zapret/
├── bin/                          ← winws.exe, WinDivert (из официального релиза)
├── lists/                        ← списки доменов и IP
├── .service/                     ← шаблоны hosts, version.txt
├── setup-megafon.bat             ← ★ начните отсюда
├── setup-dns-megafon.bat
├── setup-youtube-hosts.bat
├── general (MEGAFON).bat         ← ★ основная стратегия
├── general Megafon.bat
├── service.bat
└── README.md
```

---

## Автозапуск

После проверки рабочей стратегии:

1. `service.bat` → **Install Service**
2. Выберите `general (MEGAFON).bat`

---

## Благодарности

- [Flowseal/zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube) — сборка и стратегии для Windows
- [bol-van/zapret](https://github.com/bol-van/zapret) — ядро обхода DPI
- Пользователи [Issue #15479](https://github.com/Flowseal/zapret-discord-youtube/issues/15479) — описание массовой проблемы с YouTube

---

## Лицензия

См. [LICENSE.txt](./LICENSE.txt). Исходный проект распространяется на условиях upstream-репозитория Flowseal.
