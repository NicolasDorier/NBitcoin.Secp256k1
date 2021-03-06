FROM ubuntu:xenial

RUN apt-get update && apt-get -y install cmake git build-essential vim python wget autoconf libtool

RUN cd /tmp && \
    wget -qO "wasi-sdk.tar.gz" "https://github.com/CraneStation/wasi-sdk/releases/download/wasi-sdk-4/wasi-sdk-4.0-linux-amd64.tar.gz" && \
    mkdir /opt/wasi-sdk && \
    tar --strip-components=3 -xzvf "wasi-sdk.tar.gz" -C /opt/wasi-sdk && \
    rm /tmp/wasi-sdk.tar.gz && \
    cd /tmp && \
    wget -qO "wabt.tar.gz" "https://github.com/WebAssembly/wabt/releases/download/1.0.10/wabt-1.0.10-linux.tar.gz" && \
    tar --strip-components=1 -xzvf "wabt.tar.gz" -C /usr/bin && \
    rm /tmp/wabt.tar.gz

WORKDIR /src
RUN git clone https://github.com/bitcoin-core/secp256k1/ && cd secp256k1 && git checkout b19c000063be11018b4d1a6b0a85871ab9d0bdcf

ENV CC="/opt/wasi-sdk/bin/clang" \
CXX="/opt/wasi-sdk/bin/clang++" \
LD="/opt/wasi-sdk/bin/wasm-ld" \
AR="/opt/wasi-sdk/bin/llvm-ar" \
HOST="wasm32-unknown-wasi" \
CFLAGS="--sysroot=/opt/wasi-sdk/share/sysroot --target=wasm32-unknown-wasi"

WORKDIR /src/secp256k1
VOLUME /build
RUN ./autogen.sh
RUN grep -q -F -- '-wasi' build-aux/config.sub || sed -i -e 's/-nacl\*)/-nacl*|-wasi)/' build-aux/config.sub
COPY remove_printf.patch remove_printf.patch
RUN git apply remove_printf.patch
RUN ./configure --prefix=/build --enable-endomorphism --enable-module-ecdh \
                --enable-module-recovery --with-asm=no --host=wasm32-unknown-wasi \
                --with-bignum=no --enable-experimental \
                --disable-exhaustive-tests --disable-tests \
                --disable-benchmark
RUN make && ${CC} ${CFLAGS} src/libsecp256k1_la-secp256k1.o -o libsecp256k1.wasm -Xlinker -shared -Xlinker --no-entry
ENTRYPOINT bash -c "make install && \
                    cd /build/lib && \
                    cp /src/secp256k1/libsecp256k1.wasm libsecp256k1.wasm && \
                    wasm2wat libsecp256k1.wasm -o libsecp256k1.wat"