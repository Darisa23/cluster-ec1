FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server openssh-client sudo \
    openmpi-bin libopenmpi-dev \
    nfs-kernel-server nfs-common \
    python3 python3-pip iputils-ping net-tools nano \
    && rm -rf /var/lib/apt/lists/*

# Paso 1 de la actividad: usuario ec1 con privilegios de administrador
RUN useradd -m -s /bin/bash ec1 && \
    echo "ec1:ec1" | chpasswd && \
    usermod -aG sudo ec1 && \
    echo "ec1 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ec1

# Paso 2: passwordless login (misma llave en todos los nodos)
RUN mkdir -p /home/ec1/.ssh /var/run/sshd && \
    ssh-keygen -t rsa -b 2048 -f /home/ec1/.ssh/id_rsa -N "" && \
    cp /home/ec1/.ssh/id_rsa.pub /home/ec1/.ssh/authorized_keys && \
    printf "Host *\n  StrictHostKeyChecking no\n  UserKnownHostsFile /dev/null\n" > /home/ec1/.ssh/config && \
    chmod 700 /home/ec1/.ssh && \
    chmod 600 /home/ec1/.ssh/id_rsa /home/ec1/.ssh/authorized_keys /home/ec1/.ssh/config && \
    chown -R ec1:ec1 /home/ec1/.ssh

# Evitar que MPI se queje de ejecutar como root/usuario
ENV OMPI_MCA_btl_vader_single_copy_mechanism=none
ENV OMPI_MCA_plm_rsh_agent=ssh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
