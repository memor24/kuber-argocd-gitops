FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY myapp.py .

EXPOSE 6666

CMD [ "gunicorn", "--bind", "0.0.0.0:6666", "myapp:app"]
