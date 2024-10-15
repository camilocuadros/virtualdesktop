# Usamos la imagen base de Ubuntu
FROM ubuntu:20.04

# Desactivar la interacción para evitar prompts
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar el índice de paquetes, instalar tzdata y actualizar el sistema
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    tzdata \
    && ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Instalar XFCE y otros paquetes necesarios
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    dbus-x11 \
    x11-xserver-utils \
    supervisor \
    xterm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear el usuario para la sesión VNC
RUN useradd -ms /bin/bash ubuntu

# Configuración de VNC
RUN mkdir -p /home/ubuntu/.vnc \
    && echo "ubuntu" | vncpasswd -f > /home/ubuntu/.vnc/passwd \
    && chown -R ubuntu:ubuntu /home/ubuntu/.vnc \
    && chmod 600 /home/ubuntu/.vnc/passwd

# Instalar scripts de inicio para el servidor VNC
RUN echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > /home/ubuntu/.vnc/xstartup \
    && chmod +x /home/ubuntu/.vnc/xstartup

# Configuración de supervisor para mantener el VNC activo
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponer el puerto VNC
EXPOSE 5901

# Comando de inicio
CMD ["/usr/bin/supervisord"]
