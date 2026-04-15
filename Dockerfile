FROM registry.cern.ch/alisw/slc9-gpu-builder@sha256:ea3443f9dfbc770e4b4bce0d1a9ecc0b7a7c16e9f76e416b796d170877220820
COPY install.sh /tmp
RUN bash /tmp/install.sh && rm -f /tmp/install.sh /root/anaconda-ks.cfg /root/original-ks.cfg

