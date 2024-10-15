FROM ubuntu:20.04

# Actualizar e instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    sudo \
    wget \
    curl \
    software-properties-common \
    dbus-x11 \
    x11-xserver-utils \
    unzip \
    && apt-get clean

# Configurar el entorno gráfico
RUN useradd -m remoteuser && echo "remoteuser:password" | chpasswd && adduser remoteuser sudo
RUN echo "xfce4-session" > /home/remoteuser/.xsession

# Descargar e instalar Google Chrome (necesario para Google Remote Desktop)
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb || apt-get install -f -y

# Descargar e instalar Google Remote Desktop
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
    dpkg -i chrome-remote-desktop_current_amd64.deb || apt-get install -f -y

# Configurar Google Remote Desktop
RUN usermod -a -G chrome-remote-desktop remoteuser

# Exponer el puerto para Google Remote Desktop (no es necesario abrir puertos adicionales)
EXPOSE 3389

# Iniciar sesión automática y ejecutar XFCE4 cuando se conecte con Google Remote Desktop
CMD /opt/google/chrome-remote-desktop/start-host --code="$REMOTE_DESKTOP_ACCESS_CODE" --redirect-url="https://remotedesktop.google.com/" --name="Ubuntu-Google-Remote-Desktop"

