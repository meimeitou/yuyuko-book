image:
	@docker build -t yuyuko-book:latest .

push:
	@docker push yuyuko-book:latest

build:
	@hugo

run:
	@hugo server -D

run-docker:
	@docker run --rm -d -p 8888:80 --name yuyuko-book yuyuko-book:latest

stop:
	@docker stop yuyuko-book

new:
	@hugo new $(md)