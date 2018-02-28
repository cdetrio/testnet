FROM ethereum/cpp-build-env

ENV BUILD_TYPE=Release
ENV CXX=clang++-5.0
ENV CC=clang-5.0
ENV GENERATOR=Ninja

# WORKDIR is /home/builder

RUN apk add --no-cache \
        bash jq bc \
        python3 \
        libstdc++ \
        gmp \
        libcurl \
        libmicrohttpd

RUN git clone --recursive https://github.com/ethereum/cpp-ethereum --branch develop --single-branch --depth 1
RUN cd cpp-ethereum/hera \
  && git pull origin master

RUN cd cpp-ethereum && echo "{}"                                         \
          | jq ".+ {\"repo\":\"$(git config --get remote.origin.url)\"}" \
          | jq ".+ {\"branch\":\"$(git rev-parse --abbrev-ref HEAD)\"}"  \
          | jq ".+ {\"commit\":\"$(git rev-parse HEAD)\"}"               \
          > /cpp-ethereum-version.json

RUN cd cpp-ethereum/hera && echo "{}"                                    \
          | jq ".+ {\"repo\":\"$(git config --get remote.origin.url)\"}" \
          | jq ".+ {\"branch\":\"$(git rev-parse --abbrev-ref HEAD)\"}"  \
          | jq ".+ {\"commit\":\"$(git rev-parse HEAD)\"}"               \
          > /hera-version.json

RUN mkdir build
RUN cd build && cmake ../cpp-ethereum -DCMAKE_BUILD_TYPE=RelWithDebInfo -DHERA=ON
RUN cd build && make -j8
RUN cd build && make install


ADD ewasm-testnet-cpp-config.json /ewasm-testnet-cpp-config.json

ADD cpp-eth.sh /cpp-eth.sh

#USER builder
#WORKDIR /home/builder

# Export the usual networking ports to allow outside access to the node
EXPOSE 8545 30303

ENTRYPOINT ["/cpp-eth.sh"]
