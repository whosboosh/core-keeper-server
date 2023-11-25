FROM cm2network/steamcmd:root


RUN apt-get update -yy && apt-get install -yy libxi6 xvfb
RUN apt-get install -y wget libcurl4-openssl-dev

USER steam

# Install CoreKeeper Server
ENV CPU_MHZ="2000"
ENV LD_LIBRARY_PATH="/root/.local/share/Steam/steamcmd/linux64:/root/.local/share/Steam/steamcmd/linux32:$LD_LIBRARY_PATH"
RUN ./steamcmd.sh +@sSteamCmdForcePlatformBitness 64 +force_install_dir /opt/corekeeper +login anonymous +app_update 1007 +app_update 1963720 +quit


WORKDIR /opt/corekeeper

# When running the the script, default to launching the game
ENTRYPOINT [ "/bin/bash", "_launch.sh" ] 

# Expose ports
EXPOSE 27015/udp \
    27016/udp
