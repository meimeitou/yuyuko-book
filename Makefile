image:
	@docker build -t meimeitou/yuyuko-book:latest .

push:
	@docker push meimeitou/yuyuko-book:latest

build:
	@hugo

run:
	@hugo server -D

run-docker:
	@docker run --rm -d -p 8888:80 --name yuyuko-book meimeitou/yuyuko-book:latest

stop:
	@docker stop yuyuko-book

new:
	@hugo new $(md)