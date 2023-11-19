# steamcmd/steamcmd:debian-12
FROM steamcmd/steamcmd@sha256:ee8061a6045ab78072080cd3b65b16f987c84c58ab7c349af03a0275214d64ac AS fetcher
ARG BRANCH=NONE
ARG MOUNT=

RUN <<EOF
# gmod
steamcmd +force_install_dir /opt/gmod \
    +login anonymous \
    +app_update 4020 -validate -beta ${BRANCH} \
    +quit

# mounts
printf '"mountcfg"\n{\n'        > /opt/gmod/garrysmod/cfg/mount.cfg
printf '"gamedepotsystem"\n{\n' > /opt/gmod/garrysmod/cfg/mountdepots.txt

IFS=','; for fullmnt in ${MOUNT}; do
    IFS=':' read -r gamename gameid <<EOF2
$fullmnt
EOF2
    gamepath="/opt/gmod/mounts/$gamename"
    steamcmd +force_install_dir "$gamepath" \
        +login anonymous \
        +app_update "$gameid" -validate \
        +quit

    printf '\t"%s"\t"%s"\n' "$gamename" "$gamepath" >> /opt/gmod/garrysmod/cfg/mount.cfg
    printf '\t"%s"\t"1"\n'  "$gamename"             >> /opt/gmod/garrysmod/cfg/mountdepots.txt
done

printf '}\n' >> /opt/gmod/garrysmod/cfg/mount.cfg
printf '}\n' >> /opt/gmod/garrysmod/cfg/mountdepots.txt
EOF

FROM frolvlad/alpine-glibc
ARG UID=1000
ARG GID=1000
RUN apk add --no-cache gcc

USER ${UID}:${GID}
EXPOSE 27015/tcp 27015/udp

COPY --chown=${UID}:${GID} --from=fetcher --link /opt/gmod /opt/gmod
COPY --chown=${UID}:${GID} --link . /overlay/
RUN <<EOF
ln -s /opt/gmod/garrysmod/cache/steam_cache /opt/gmod/steam_cache
ln -s /opt/gmod/garrysmod/data/sv.db        /opt/gmod/garrysmod/sv.db

mkdir -p /opt/gmod/garrysmod/cache/steam_cache
mkdir -p /opt/gmod/garrysmod/data
touch /opt/gmod/garrysmod/data/sv.db

rm -rf /overlay/docker
cp -R /overlay/. /opt/gmod/garrysmod
EOF
COPY --chown=0:0 --chmod=755 --link docker/gmod-entrypoint.sh /entrypoint.sh

VOLUME ["/opt/gmod/garrysmod/cache", "/opt/gmod/garrysmod/data"]
WORKDIR /opt/gmod
ENTRYPOINT /entrypoint.sh
