REPO_NAME=bad-news-fader
VENV_ACTIVATE=. .venv/bin/activate
PYTHON=.venv/bin/python
DOCKER_TAG=artdgn/$(REPO_NAME)
DOCKER_DATA_ARG=-v $(realpath ./data):/app/data
PORT=8000

.venv:
	python3 -m venv .venv

requirements: .venv
	$(VENV_ACTIVATE); \
	pip install -U pip; \
	pip install -U pip-tools; \
	pip-compile requirements.in

install: .venv
	$(VENV_ACTIVATE); \
	pip install -r requirements.txt

kill-server:
	kill -9 `netstat -tulpn | grep $(PORT) | grep -oP "(?<=)\d+(?=\/)"`

server:
	$(VENV_ACTIVATE); \
	python server.py

build-docker:
	docker build -t $(DOCKER_TAG) .

docker-server: build-docker
	docker run -dit \
	$(DOCKER_DATA_ARG) \
	$(DOCKER_TIME_ARG) \
	--name $(REPO_NAME) \
	-p $(PORT):$(PORT) \
	--restart unless-stopped \
	$(DOCKER_TAG)
