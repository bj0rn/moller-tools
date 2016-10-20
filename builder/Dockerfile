FROM centos:7

RUN yum install -y docker curl
ADD build.sh /usr/bin/build.sh

ENTRYPOINT ["/usr/bin/build.sh"]

