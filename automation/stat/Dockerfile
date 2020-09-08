FROM debian
WORKDIR /
RUN  apt-get update  && apt-get  install sysstat net-tools fio  iperf3 -y
COPY stat-run.sh /
COPY wait.sh / 
RUN chmod u+x stat-run.sh
CMD ["./stat-run.sh"]