FROM python:3.11-slim

WORKDIR /app

COPY attachment_api/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY attachment_api/ .

EXPOSE 8080

CMD gunicorn config.wsgi:application --bind 0.0.0.0:${PORT:-8080} --log-file -
