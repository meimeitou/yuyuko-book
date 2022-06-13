FROM klakegg/hugo:0.92.1 as build

COPY . /src
WORKDIR /src
RUN hugo

FROM nginx:1.18

COPY --from=build /src/public /etc/nginx/public
COPY ./default.conf /etc/nginx/conf.d/default.conf

RUN set -xe \
    && chown -R nobody:nobody /etc/nginx/public 
