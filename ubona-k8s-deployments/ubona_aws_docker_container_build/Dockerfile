# Use the base image of Amazon Linux 2023
FROM amazonlinux:latest

ARG USER=appuser
ARG GROUP=enterprise

# Set the hostname during container boot up
ARG HOSTNAME
ENV HOSTNAME $HOSTNAME
RUN echo "HOSTNAME=${HOSTNAME}" >> /etc/sysconfig/network

# Set proxy environment variables
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ENV http_proxy=${HTTP_PROXY} \
    https_proxy=${HTTPS_PROXY} \
    no_proxy=${NO_PROXY}

# Install nginx
RUN  yum update && \
     yum install -y nginx && \
     yum install zip unzip && \
     yum erase 'ntp*' && \
     yum install chrony && \
     sed -e '/^server / s/^#*/#/' -i /etc/chrony.conf && \
     echo -e "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >>/etc/chrony.conf && \
     service chronyd restart && \
     chkconfig chronyd on && \
     chronyc sources -v && \
     curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
     unzip awscliv2.zip && \
     ./aws/install && \
      rm -rf awscliv2.zip

RUN echo ZONE="Asia/Kolkata" >> /etc/sysconfig/clock
RUN ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

# Create appuser and enterprise group, set permissions
RUN groupadd ${GROUP} && \
    useradd -g ${GROUP} ${USER}

# Allow appuser SSH access as sudoer
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Allow the appuser to access /var/log/nginx
RUN usermod -aG nginx ${USER} && \
    chown -R :nginx /var/log/nginx && \
    chmod -R g+rx /var/log/nginx

# COPY all neccessary configuration to nginx location
COPY security.conf /etc/nginx/default.d/security.conf
#COPY nginx.conf /etc/nginx/nginx.conf
COPY error_handler.conf /etc/nginx/default.d/error_handler.conf

COPY logo.png /usr/share/nginx/html/logo.png
COPY index.html /usr/share/nginx/html/index.html
COPY custom_400.html /usr/share/nginx/html/custom_400.html
COPY custom_403.html /usr/share/nginx/html/custom_403.html
COPY custom_404.html /usr/share/nginx/html/custom_404.html
COPY custom_405.html /usr/share/nginx/html/custom_405.html
COPY custom_50x.html /usr/share/nginx/html/custom_50x.html

# Disable SELinux
#RUN sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux

# expose both the HTTP (80) ports
EXPOSE 80

# Start nginx
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]