FROM ubuntu:xenial

RUN apt update && \
  apt install -qy git-core language-pack-en libmysqlclient-dev ntp libssl-dev python3.5 python3-pip python3.5-dev && \
  pip3 install --upgrade pip setuptools && \
  rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/pip3 /usr/bin/pip
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN useradd -m --shell /bin/false app
RUN mkdir -p /edx/app/log/
RUN touch /edx/app/log/edx.log
RUN chown app:app /edx/app/log/edx.log

WORKDIR /edx/app/xqueue

# RUN python3 -m venv /edx/app/xqueue_venv
COPY requirements /edx/app/xqueue/requirements
COPY requirements.txt /edx/app/xqueue/requirements.txt

#RUN . /edx/app/xqueue_venv/bin/activate && pip install -U pip
#RUN . /edx/app/xqueue_venv/bin/activate && pip -V
#RUN . /edx/app/xqueue_venv/bin/activate && pip install -r requirements.txt
RUN pip install -U pip && pip install -r requirements.txt

USER app
EXPOSE 18040
CMD gunicorn -c /edx/app/xqueue/xqueue/docker_gunicorn_configuration.py --bind=0.0.0.0:18040 --workers 2 --max-requests=1000 xqueue.wsgi:application
COPY . /edx/app/xqueue

