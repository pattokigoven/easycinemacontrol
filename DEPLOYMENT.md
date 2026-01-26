# 📦 Инструкция по развертыванию

## 🖥️ Развертывание на Windows

### 1. Установка Python
1. Скачайте Python 3.8+ с [python.org](https://www.python.org/downloads/)
2. При установке отметьте "Add Python to PATH"
3. Проверьте установку:
```bash
python --version
```

### 2. Клонирование проекта
```bash
git clone <repository-url>
cd lighttms
```

### 3. Установка зависимостей
```bash
pip install -r requirements.txt
```

### 4. Настройка конфигурации
1. Скопируйте пример конфигурации:
```bash
copy halls_config.example.json halls_config.json
```

2. Отредактируйте `halls_config.json` под ваши залы:
```json
{
  "halls": [
    {
      "id": "hall1",
      "name": "Зал 1",
      "ip": "192.168.1.61",
      "port": 43748
    }
  ]
}
```

### 5. Запуск
```bash
python barco_multi_hall.py
```

Сервер запустится на `http://0.0.0.0:5000`

### 6. Автозапуск (Windows)
Создайте файл `start.bat`:
```batch
@echo off
cd /d "C:\lighttms"
python barco_multi_hall.py
pause
```

Добавьте ярлык в автозагрузку:
- `Win+R` → `shell:startup`
- Создайте ярлык на `start.bat`

---

## 🐧 Развертывание на Linux

### 1. Установка зависимостей
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip git

# CentOS/RHEL
sudo yum install python3 python3-pip git
```

### 2. Клонирование проекта
```bash
git clone <repository-url>
cd lighttms
```

### 3. Создание виртуального окружения
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 4. Настройка конфигурации
```bash
cp halls_config.example.json halls_config.json
nano halls_config.json
```

### 5. Запуск
```bash
python barco_multi_hall.py
```

### 6. Автозапуск (systemd)
Создайте `/etc/systemd/system/barco.service`:
```ini
[Unit]
Description=Barco ICMP Multi-Hall Control
After=network.target

[Service]
Type=simple
User=your_user
WorkingDirectory=/path/to/lighttms
Environment="PATH=/path/to/lighttms/venv/bin"
ExecStart=/path/to/lighttms/venv/bin/python barco_multi_hall.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Активация:
```bash
sudo systemctl daemon-reload
sudo systemctl enable barco
sudo systemctl start barco
sudo systemctl status barco
```

---

## 🍎 Развертывание на macOS

### 1. Установка Homebrew (если не установлен)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Установка Python
```bash
brew install python3
```

### 3. Клонирование и настройка
```bash
git clone <repository-url>
cd lighttms
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp halls_config.example.json halls_config.json
nano halls_config.json
```

### 4. Запуск
```bash
python barco_multi_hall.py
```

### 5. Автозапуск (LaunchAgent)
Создайте `~/Library/LaunchAgents/com.cinema.barco.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.cinema.barco</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/lighttms/venv/bin/python</string>
        <string>/path/to/lighttms/barco_multi_hall.py</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/path/to/lighttms</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Активация:
```bash
launchctl load ~/Library/LaunchAgents/com.cinema.barco.plist
```

---

## 🐳 Развертывание через Docker

### Dockerfile (уже создан)
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "barco_multi_hall.py"]
```

### Сборка и запуск
```bash
# Сборка образа
docker build -t barco-control .

# Запуск контейнера
docker run -d \
  --name barco \
  -p 5000:5000 \
  -v $(pwd)/halls_config.json:/app/halls_config.json \
  -v $(pwd)/logs:/app/logs \
  --restart unless-stopped \
  barco-control
```

### Docker Compose (уже создан)
```bash
docker-compose up -d
```

---

## 🔧 Настройка сети

### Проверка доступности проекторов
```bash
# Windows
ping 192.168.1.61

# Linux/Mac
ping -c 4 192.168.1.61

# Проверка порта
telnet 192.168.1.61 43748
# или
nc -zv 192.168.1.61 43748
```

### Открытие порта в файрволе

#### Windows
```powershell
New-NetFirewallRule -DisplayName "Barco Control" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
```

#### Linux (ufw)
```bash
sudo ufw allow 5000/tcp
```

#### Linux (firewalld)
```bash
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

---

## 📱 Настройка для внешнего доступа

### Вариант 1: Локальная сеть
Доступ по IP сервера: `http://192.168.1.100:5000`

### Вариант 2: Nginx Reverse Proxy (рекомендуется для продакшена)

#### Установка Nginx
```bash
# Ubuntu/Debian
sudo apt install nginx

# CentOS/RHEL
sudo yum install nginx
```

#### Конфигурация (`/etc/nginx/sites-available/barco`)
```nginx
server {
    listen 80;
    server_name barco.cinema.local;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Активация:
```bash
sudo ln -s /etc/nginx/sites-available/barco /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Вариант 3: HTTPS с Let's Encrypt
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d barco.cinema.local
```

---

## 🔐 Безопасность

### 1. Измените SECRET_KEY
В `barco_multi_hall.py`:
```python
app.config['SECRET_KEY'] = 'ваш-случайный-секретный-ключ'
```

Генерация:
```python
import secrets
print(secrets.token_hex(32))
```

### 2. Ограничьте доступ по IP (опционально)
Nginx:
```nginx
location / {
    allow 192.168.1.0/24;
    deny all;
    proxy_pass http://127.0.0.1:5000;
}
```

### 3. Регулярно обновляйте зависимости
```bash
pip install --upgrade -r requirements.txt
```

---

## 📊 Мониторинг

### Просмотр логов
```bash
# Логи приложения
tail -f logs/admin_actions_*.log

# Логи systemd (Linux)
sudo journalctl -u barco -f

# Логи Docker
docker logs -f barco
```

### Проверка статуса
```bash
# systemd
sudo systemctl status barco

# Docker
docker ps | grep barco
```

---

## 🆘 Решение проблем

### Проблема: Порт занят
```bash
# Windows
netstat -ano | findstr :5000

# Linux/Mac
lsof -i :5000
```

Остановите процесс или измените порт в коде:
```python
socketio.run(app, host='0.0.0.0', port=5001)
```

### Проблема: Не подключается к проектору
1. Проверьте IP и порт в `halls_config.json`
2. Проверьте сетевое подключение (ping)
3. Убедитесь, что проектор включен
4. Проверьте, что ICMP протокол включен на проекторе

### Проблема: Ошибка импорта модулей
```bash
pip install --force-reinstall -r requirements.txt
```

---

## 🔄 Обновление

```bash
cd lighttms
git pull
pip install -r requirements.txt

# Перезапуск
# Windows
taskkill /F /IM python.exe
python barco_multi_hall.py

# Linux (systemd)
sudo systemctl restart barco

# Docker
docker-compose down
docker-compose up -d --build
```

---

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `logs/admin_actions_*.log`
2. Проверьте консоль сервера
3. Создайте Issue на GitHub
