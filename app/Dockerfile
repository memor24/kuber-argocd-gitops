FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY src/my-app.py .

EXPOSE 6666

CMD [ "gunicorn", "--bind", "0.0.0.0:6666", "my-app:app"]
