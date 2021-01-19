# FROM postgres:9.4
# RUN localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
# ENV LANG de_DE.utf8

# # COPY data /var/local/
# # COPY setup.sh /docker-entrypoint-initdb.d/
# # FROM alpine
# CMD ["echo", "testing..."]

FROM alpine
CMD ["echo", "i am groot"]