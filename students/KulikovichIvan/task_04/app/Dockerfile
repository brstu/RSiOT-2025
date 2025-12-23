FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV STU_ID=220015
ENV STU_GROUP=as-63
ENV STU_VARIANT=11
ENV METRICS_PREFIX=app11_

EXPOSE 8080

CMD ["python", "main.py"]