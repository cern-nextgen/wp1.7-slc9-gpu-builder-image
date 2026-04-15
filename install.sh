#! /bin/bash

export GIT_DIR=/tmp/clang-p2996
export BUILD_DIR=/tmp/build
export INSTALL_DIR=/usr

dnf install -y lld
dnf clean all

git clone --depth 1 --branch p2996 https://github.com/bloomberg/clang-p2996.git ${GIT_DIR}
cmake -S ${GIT_DIR}/llvm -B ${BUILD_DIR} -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DLLVM_ENABLE_LLD=ON \
        -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON -DLLVM_APPEND_VC_REV=OFF -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;lld' -DLLVM_ENABLE_RUNTIMES="libc;libcxx;libcxxabi;libunwind" \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_DOCS=OFF \
        -DLLVM_BUILD_BENCHMARKS=OFF -DLIBCXX_INSTALL_MODULES=ON -DLLDB_ENABLE_PYTHON=0 
cmake --build ${BUILD_DIR} --target install -j $(nproc)
rm -rf ${GIT_DIR} ${BUILD_DIR}

