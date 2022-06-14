image:
	@docker build -t roygbip/yuyuko-book:latest .

push:
	@docker push roygbip/yuyuko-book:latest

build:
	@hugo

run:
	@hugo server -D

run-docker:
	@docker run --rm -d -p 8888:80 --name yuyuko-book roygbip/yuyuko-book:latest

stop:
	@docker stop yuyuko-book

new:
	@hugo new $(md)