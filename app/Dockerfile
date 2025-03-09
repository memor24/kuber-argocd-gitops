FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY src/myapp.py src/tests/myapp-test.py .

EXPOSE 8080

CMD [ "gunicorn", "--bind", "0.0.0.0:8080", "my-app:app"]
