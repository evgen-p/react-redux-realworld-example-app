FROM alpine:latest AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN apk add nodejs npm && npm install
COPY . .
RUN npm run build

ARG THTTPD_VERSION=2.29

# Install all dependencies required for compiling thttpd
RUN apk add gcc musl-dev make

WORKDIR /
# Download thttpd sources
RUN wget http://www.acme.com/software/thttpd/thttpd-${THTTPD_VERSION}.tar.gz \
  && tar xzf thttpd-${THTTPD_VERSION}.tar.gz \
    && mv /thttpd-${THTTPD_VERSION} /thttpd

# Compile thttpd to a static binary which we can copy around
RUN cd /thttpd \
&& ./configure \
&& make CCOPT='-O2 -s -static' thttpd

# Create a non-root user to own the files and run our server
RUN adduser -D static

FROM scratch
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /thttpd/thttpd /
USER static
WORKDIR /home/static
COPY --from=builder /usr/src/app/build/ .
