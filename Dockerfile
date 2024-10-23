FROM ubuntu:24.04

WORKDIR /tmp

RUN apt-get update

RUN apt-get -y install curl tar gzip
RUN apt-get -y install python3
RUN apt-get -y install pip
RUN python3 --version
RUN apt-get -y install python3.8-venv
RUN python3 -mvenv .venv

RUN /bin/bash -c "source .venv/bin/activate && \
    pip install --upgrade pip \
    "
RUN /bin/bash -c "source .venv/bin/activate && \
    pip install ansible 'molecule-plugins[docker]' \
    "
RUN /bin/bash -c "source .venv/bin/activate && \
    molecule init role taylorm.mytest -d docker && \
    ls -lad \
    "
RUN /bin/bash -c "echo source .venv/bin/activate >>~/.bashrc"

RUN bash -c "$(curl https://raw.githubusercontent.com/taylormonacelli/ringgem/master/install-golang-from-tar.sh)"
RUN /usr/local/go/bin/go install github.com/rogpeppe/go-internal/cmd/txtar-x@latest

COPY test.txtar .

RUN echo 'export GOPATH=$HOME/go/bin' >>~/.bashrc
RUN echo 'export PATH=$PATH:$HOME/go/bin:/usr/local/go/bin:$GOPATH/bin' >>~/.bashrc
RUN $HOME/go/bin/txtar-x test.txtar

RUN ls -la