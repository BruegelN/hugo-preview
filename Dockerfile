FROM golang:1.15.2 AS builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /build

COPY go.mod go.sum /build/

RUN go mod download
RUN go mod verify

COPY . /build/

ENV LD_FLAGS="-w"
ENV CGO_ENABLED=0

RUN go install -v -tags netgo -ldflags "${LD_FLAGS}" .

RUN wget -O /tmp/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v0.75.1/hugo_0.75.1_Linux-64bit.tar.gz \
 && tar xvzf /tmp/hugo.tar.gz -C /tmp

FROM busybox

LABEL maintainer="Robert Jacob <xperimental@solidproject.de>"
EXPOSE 8080
USER nobody
ENTRYPOINT ["/bin/hugo-preview"]

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/bin/hugo-preview /tmp/hugo /bin/
