FROM klakegg/hugo:0.95.0 as build

COPY . /src
WORKDIR /src
RUN hugo

FROM nginx:1.18

COPY --from=build /src/public /etc/nginx/public
COPY ./default.conf /etc/nginx/conf.d/default.conf
