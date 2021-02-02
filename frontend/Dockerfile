FROM python:3

WORKDIR .

ENV FLASK_APP=main.py
ENV FLASK_RUN_HOST=0.0.0.0

COPY requirements.txt ./

RUN pip3 install -r requirements.txt

EXPOSE 5000
COPY . .

CMD [ "python3", "./main.py" ]
