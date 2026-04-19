# ---------- CLANG builder stage ----------
FROM registry.cern.ch/alisw/slc9-builder@sha256:03a5ace61358dedb7b0af205a26bf05b8e9a9cd429385eeb34a00c86c18b637e as clang-builder

ENV CLANG_SOURCE=/tmp/clang-p2996
ENV CLANG_BUILD=/tmp/clang-build
ENV CLANG_INSTALL_PREFIX=/opt/clang-p2996

RUN dnf install -y cmake lld \
    && git clone --depth 1 --branch p2996 https://github.com/bloomberg/clang-p2996.git ${CLANG_SOURCE} \
    && cmake -S ${CLANG_SOURCE}/llvm -B ${CLANG_BUILD} \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_CXX_COMPILER=g++ \
        -DLLVM_ENABLE_LLD=ON \
        -DLLVM_BUILD_LLVM_DYLIB=ON \
        -DLLVM_LINK_LLVM_DYLIB=ON \
        -DLLVM_APPEND_VC_REV=OFF \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" \
        -DLLVM_ENABLE_RUNTIMES="libc;libcxx;libcxxabi;libunwind" \
        -DCMAKE_INSTALL_PREFIX=${CLANG_INSTALL_PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_BUILD_DOCS=OFF \
        -DLLVM_BUILD_BENCHMARKS=OFF \
        -DLIBCXX_INSTALL_MODULES=ON \
        -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON \
    && cmake --build ${CLANG_BUILD} --target install -j $(nproc)


# ---------- GCC builder stage ----------
FROM registry.cern.ch/alisw/slc9-builder@sha256:03a5ace61358dedb7b0af205a26bf05b8e9a9cd429385eeb34a00c86c18b637e AS gcc-builder

ENV GCC_SOURCE=/tmp/gcc
ENV GCC_BUILD=/tmp/gcc-build
ENV GCC_INSTALL_PREFIX=/opt/gcc

RUN git clone --depth 1 https://gcc.gnu.org/git/gcc.git ${GCC_SOURCE}

WORKDIR ${GCC_SOURCE}

RUN ./contrib/download_prerequisites

WORKDIR ${GCC_BUILD}

RUN ${GCC_SOURCE}/configure \
        --prefix=${GCC_INSTALL_PREFIX} \
        --disable-multilib \
        --enable-languages=c,c++ \
        --enable-checking=release \
    && make -j $(nproc) \
    && make install


# ---------- Final runtime stage ----------
FROM registry.cern.ch/alisw/slc9-builder@sha256:03a5ace61358dedb7b0af205a26bf05b8e9a9cd429385eeb34a00c86c18b637e

COPY --from=clang-builder /opt/clang-p2996 /opt/clang-p2996
COPY --from=gcc-builder /opt/gcc /opt/gcc
