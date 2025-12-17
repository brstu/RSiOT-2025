FROM python:3.11

LABEL org.bstu.student.fullname="Попов Алексей Сергеевич"
LABEL org.bstu.student.id="220051"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="38"
LABEL org.bstu.course="RSiOT"

WORKDIR /app

COPY app.py .

ENV PORT=8002
ENV STU_ID=220051
ENV STU_GROUP=AS-64
ENV STU_VARIANT=38

EXPOSE 8002

CMD ["python", "app.py"]
