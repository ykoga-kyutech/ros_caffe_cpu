FROM ykoga/caffe_cpu

# Get dependencies
RUN apt-get update && apt-get install -q -y \
  ros-indigo-uvc-camera \
  tmux \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /root

# clone omnimapper project
RUN mkdir -p catkin_ws/src \
  && cd catkin_ws/src \
  && git clone https://github.com/ruffsl/ros_caffe.git

# added by yuta
RUN cd catkin_ws/src/ros_caffe && \
  sed -i '/#add_definitions(-DCPU_ONLY=1)/s/^#//' CMakeLists.txt && \
  sed -i '/find_package(CUDA REQUIRED)/s/^/#/' CMakeLists.txt && \
  sed -i '/${CUDA_INCLUDEDIR}/s/^/#/' CMakeLists.txt && \
  sed -i '/^  *cuda/s/^/#/' CMakeLists.txt

ADD ros_caffe.launch /root/catkin_ws/src/ros_caffe/launch/ros_caffe.launch
ADD ros_caffe_webcam_mine.launch /root/catkin_ws/src/ros_caffe/launch/ros_caffe_webcam_mine.launch
ADD caffe_result_pub.py /root/

# build omnimapper ros wrapper
ADD build.sh catkin_ws/src/ros_caffe/build.sh
RUN ./catkin_ws/src/ros_caffe/build.sh
RUN echo "source catkin_ws/devel/setup.bash" >> /root/.bashrc
RUN /bin/bash -c 'source /root/.bashrc'

# get model
RUN cd /root/catkin_ws/src/ros_caffe \
  && python get_model.py
