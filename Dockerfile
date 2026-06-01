FROM busybox:musl

# version.txt is baked into the image so the running container reports its version.
COPY version.txt /version.txt
COPY app.sh /app.sh
RUN chmod +x /app.sh

ENTRYPOINT ["/app.sh"]
