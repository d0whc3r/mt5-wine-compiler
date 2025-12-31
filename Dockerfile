FROM --platform=linux/amd64 ubuntu:noble

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and Wine
# We add i386 architecture to support 32-bit libraries (WoW64)
# We install winehq-stable which includes support for both architectures if i386 is added
RUN dpkg --add-architecture i386 && \
  mkdir -pm755 /etc/apt/keyrings && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  wget \
  ca-certificates \
  gnupg \
  xvfb \
  winbind \
  cabextract && \
  wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
  wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources && \
  apt-get update && \
  apt-get install -y --install-recommends winehq-stable && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Create wine user
RUN groupadd -g 1001 wine && \
  useradd -g wine -u 1001 -m -s /bin/bash wine && \
  mkdir -p /home/wine/.mt5/drive_c/mt5 && \
  chown -R wine:wine /home/wine

USER wine
WORKDIR /home/wine

# Initialize Wine prefix
# WINEARCH=win64 allows running both 64-bit (MetaEditor64) and 32-bit applications (via WoW64)
ENV WINEPREFIX=/home/wine/.mt5
ENV WINEARCH=win64
ENV WINEDLLOVERRIDES="mscoree,mshtml="

# Run winecfg to initialize the prefix (headless)
# Using win10 as it's a good baseline for modern apps
RUN xvfb-run -a winecfg -v=win10 && \
  wineserver -w

# Copy mt5 files
# We assume the context has the 'mt5' directory with MetaEditor64.exe and sdk
ADD --chown=wine:wine mt5/MetaEditor64.tar.bz2 /home/wine/.mt5/drive_c/mt5
COPY --chown=wine:wine mt5/sdk/5.0_build-5488/Include    /home/wine/.mt5/drive_c/mt5/Include
COPY --chown=wine:wine mt5/sdk/5.0_build-5488/Indicators /home/wine/.mt5/drive_c/mt5/Indicators
COPY --chown=wine:wine mt5/sdk/5.0_build-5488/Libraries  /home/wine/.mt5/drive_c/mt5/Libraries

# Copy entrypoint script
COPY --chown=wine:wine entrypoint.sh /home/wine/entrypoint.sh
RUN chmod +x /home/wine/entrypoint.sh

ENTRYPOINT ["/home/wine/entrypoint.sh"]
