FROM hobsonspipe/centos-base

ENV CLAM_VERSION=0.99.4

RUN yum update -y && \
    yum install -y gcc openssl-devel wget make

RUN wget https://www.clamav.net/downloads/production/clamav-${CLAM_VERSION}.tar.gz && \
    tar xvzf clamav-${CLAM_VERSION}.tar.gz && \
    cd clamav-${CLAM_VERSION} && \
    ./configure && \
    make && make install && \
    yum remove -y gcc make && \
    yum clean all

# Add clamav user
RUN groupadd -r clamav && \
    useradd -r -g clamav -u 1000 clamav -d /var/lib/clamav && \
    mkdir -p /var/lib/clamav && \
    mkdir /usr/local/share/clamav && \
    chown -R clamav:clamav /var/lib/clamav /usr/local/share/clamav

# initial update of av databases
RUN wget -t 5 -T 99999 -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
    wget -t 5 -T 99999 -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
    wget -t 5 -T 99999 -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
    chown clamav:clamav /var/lib/clamav/*.cvd

# permissions
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

# Configure Clam AV...
RUN chown clamav:clamav -R /usr/local/etc/
ADD --chown=clamav:clamav ./*.conf /usr/local/etc/
ADD --chown=clamav:clamav eicar.com /
ADD --chown=clamav:clamav ./readyness.sh /

USER 1000

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3310
