FROM ubuntu:16.04 as protobuf

RUN apt-get update && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        ca-certificates \
        curl \
        g++ \
        git \
        libtool \
        make \
        python-dev \
        python-setuptools \
        unzip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /protobuf
RUN git clone -b '3.2.x' https://github.com/google/protobuf.git . && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local/protobuf && \
    make "-j$(nproc)" install


FROM nvidia/cuda:8.0-cudnn7-devel-ubuntu16.04

COPY --from=protobuf /usr/local/protobuf /usr/local

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        curl \
        g++ \
        git \
        libatlas-base-dev \
        libboost-filesystem-dev \
        libboost-python-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libnccl-dev=1.2.3-1+cuda8.0 \
        libopencv-dev \
        libsnappy-dev \
        python-all-dev \
        python-h5py \
        python-matplotlib \
        python-opencv \
        python-pil \
        python-pydot \
        python-scipy \
        python-skimage \
        python-sklearn && \
    rm -rf /var/lib/apt/lists/*

# Build pip
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    pip install --upgrade --no-cache-dir pip

# Build caffe
RUN git clone https://github.com/richardharmadi/nvcaffe-yolov2.git /caffe && \
    cd /caffe && \
    pip install ipython==5.4.1 && \
    pip install tornado==4.5.3 && \
    pip install -r python/requirements.txt && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/caffe -DUSE_NCCL=ON -DUSE_CUDNN=ON -DCUDA_ARCH_NAME=Manual -DCUDA_ARCH_BIN="35 52 60 61" -DCUDA_ARCH_PTX="61" .. && \
    make -j"$(nproc)" install && \
