FROM python:3.11-slim

# Метаданные
LABEL maintainer="Easy Cinema Control"
LABEL description="Multi-hall cinema control system for Barco ICMP"

# Рабочая директория
WORKDIR /app

# Копирование requirements и установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn eventlet

# Копирование файлов приложения
COPY barco_multi_hall.py .
COPY greetings.txt .
COPY templates/ templates/
COPY static/ static/

# Создание директории для логов
RUN mkdir -p /app/logs

# Создание непривилегированного пользователя
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Открытие порта
EXPOSE 5000

# Запуск приложения
CMD ["python", "barco_multi_hall.py"]
