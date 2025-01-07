FROM ${BASE_IMAGE}

# Cập nhật hệ thống và cài đặt các công cụ cần thiết
RUN apt-get update && apt-get install -y \
    build-essential \
    devscripts \
    debhelper \
    fakeroot \
    gnupg \
    reprepro \
    wget \
    curl \
    git \
    sudo \
    && apt-get clean

# Cập nhật hệ điều hành và cài đặt công cụ cơ bản
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y build-essential git wget curl vim sudo locales

# Thiết lập múi giờ và ngôn ngữ
RUN ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Đặt timezone để tránh yêu cầu nhập liệu khi cài đặt package
ENV DEBIAN_FRONTEND=noninteractive

# Thiết lập thư mục làm việc
WORKDIR ${WORKDIR}

# Định nghĩa lệnh chạy chính
# CMD ["/bin/bash"]

# Command mặc định khi container chạy
CMD ["dpkg-buildpackage", "--force-sign"]