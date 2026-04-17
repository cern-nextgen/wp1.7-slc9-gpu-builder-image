FROM registry.cern.ch/alisw/slc9-gpu-builder@sha256:ea3443f9dfbc770e4b4bce0d1a9ecc0b7a7c16e9f76e416b796d170877220820 as builder

ENV GIT_DIR=/tmp/clang-p2996
ENV BUILD_DIR=/tmp/build
ENV CLANG_INSTALL_DIR=/opt/clang-p2996

COPY install.sh /tmp

RUN bash /tmp/install.sh


FROM registry.cern.ch/alisw/slc9-gpu-builder@sha256:ea3443f9dfbc770e4b4bce0d1a9ecc0b7a7c16e9f76e416b796d170877220820

COPY --from=builder /opt/clang-p2996 /opt/clang-p2996
