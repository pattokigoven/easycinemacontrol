FROM python:3.11-slim

# Метаданные
LABEL maintainer="Barco ICMP Control"
LABEL description="Web interface for Barco ICMP control"

# Рабочая директория
WORKDIR /app

# Копирование requirements и установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn

# Копирование файлов приложения
COPY barco_web.py .
COPY templates/ templates/
COPY static/ static/

# Создание непривилегированного пользователя
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Открытие порта
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/api/status')"

# Запуск приложения
CMD ["gunicorn", "--worker-class", "eventlet", "-w", "1", "--bind", "0.0.0.0:5000", "--access-logfile", "-", "--error-logfile", "-", "barco_web:app"]
