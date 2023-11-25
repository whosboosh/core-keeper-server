FROM python:slim-bullseye as builder
ENV DEBIAN_FRONTEND noninteractive

# install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git build-essential cmake gcc-arm-linux-gnueabihf

# clone box86 git repo
RUN git clone https://github.com/ptitSeb/box86 && mkdir /box86/build

# compile box86
WORKDIR /box86/build
RUN mkdir /box86/install
RUN cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/box86/install -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo # -DRPI4ARM64=1 for Pi4 aarch64 (use `-DRPI3ARM64=1` for a PI3 model)
RUN make -j$(nproc)
RUN make install

FROM steamcmd/steamcmd

RUN apt-get update -yy && apt-get install -yy libxi6 xvfb
RUN apt-get install -y libcurl4-openssl-dev

RUN mkdir -p /opt/corekeeper
RUN chmod -R 777 /opt

# Install CoreKeeper Server
ENV CPU_MHZ="2000"
ENV LD_LIBRARY_PATH="/root/.local/share/Steam/steamcmd/linux64:/root/.local/share/Steam/steamcmd/linux32:$LD_LIBRARY_PATH"
RUN steamcmd +@sSteamCmdForcePlatformBitness 64 +force_install_dir /opt/corekeeper +login anonymous +app_update 1007 +app_update 1963720 +quit

# copy box86 build from above and install in container
RUN apt-get install -y make cmake
COPY --from=builder /box86/install/* /usr/bin
#RUN apt-get install -y python3 gcc-arm-linux-gnueabihf
#RUN make install RPI4ARM64=1

WORKDIR /opt/corekeeper
# When running the the script, default to launching the game
ENTRYPOINT [ "box86", "_launch.sh" ] 

# Expose ports
EXPOSE 27015/udp \
    27016/udp
