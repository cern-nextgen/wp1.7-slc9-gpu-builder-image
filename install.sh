#!/bin/bash

# ---- Required environment checks ----
: "${GIT_DIR:?GIT_DIR not set}"
: "${BUILD_DIR:?BUILD_DIR not set}"
: "${CLANG_INSTALL_DIR:?CLANG_INSTALL_DIR not set}"

# ---- Install dependencies ----
dnf install -y lld

# ---- Clone LLVM/Clang ----
git clone --depth 1 --branch p2996 https://github.com/bloomberg/clang-p2996.git "${GIT_DIR}"

# ---- Configure ----
cmake -S "${GIT_DIR}/llvm" -B "${BUILD_DIR}" \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DLLVM_ENABLE_LLD=ON \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_APPEND_VC_REV=OFF \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" \
  -DLLVM_ENABLE_RUNTIMES="libc;libcxx;libcxxabi;libunwind" \
  -DCMAKE_INSTALL_PREFIX="${CLANG_INSTALL_DIR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_BUILD_DOCS=OFF \
  -DLLVM_BUILD_BENCHMARKS=OFF \
  -DLIBCXX_INSTALL_MODULES=ON \
  -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON

# ---- Build + install ----
cmake --build "${BUILD_DIR}" --target install -j "$(nproc)"

