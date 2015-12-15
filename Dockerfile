FROM ykoga/caffe_cpu

# Get dependencies
RUN apt-get update && apt-get install -q -y \
  ros-indigo-uvc-camera \
  tmux \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /root

# clone ros_caffe project by ruffsl
RUN mkdir -p catkin_ws/src \
  && cd catkin_ws/src \
  && git clone https://github.com/ruffsl/ros_caffe.git

# modify CMakeLists for building ros_caffe package by CPU only
RUN cd catkin_ws/src/ros_caffe && \
  sed -i '/#add_definitions(-DCPU_ONLY=1)/s/^#//' CMakeLists.txt && \
  sed -i '/find_package(CUDA REQUIRED)/s/^/#/' CMakeLists.txt && \
  sed -i '/${CUDA_INCLUDEDIR}/s/^/#/' CMakeLists.txt && \
  sed -i '/^  *cuda/s/^/#/' CMakeLists.txt

# add launches for running ros_caffe only and ros_caffe + webcam + viewer
ADD ros_caffe.launch /root/catkin_ws/src/ros_caffe/launch/ros_caffe.launch
ADD ros_caffe_webcam_uvc.launch /root/catkin_ws/src/ros_caffe/launch/ros_caffe_webcam_uvc.launch
ADD test_webcam.bag /root/catkin_ws/src/

# build ros_caffe package
RUN cd catkin_ws/src/ros_caffe/ && \
  wget https://raw.githubusercontent.com/ruffsl/ros_caffe/master/docker/ros-caffe/build.sh && \
  chmod a+x build.sh && \
  ./build.sh
RUN echo "source /root/catkin_ws/devel/setup.bash" >> /root/.bashrc
RUN /bin/bash -c 'source /root/.bashrc'

# get model
RUN cd /root/catkin_ws/src/ros_caffe && \
    python get_model.py
