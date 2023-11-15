#!/bin/sh

SRCDS_PARAMS="+map ${MAP:-gm_construct}"
[ -n "$GAMEMODE" ] && SRCDS_PARAMS="$SRCDS_PARAMS +gamemode $GAMEMODE"
[ -n "$MAXPLAYERS" ] && SRCDS_PARAMS="$SRCDS_PARAMS +maxplayers $MAXPLAYERS"
[ -n "$WORKSHOPID" ] && SRCDS_PARAMS="$SRCDS_PARAMS +host_workshop_collection $WORKSHOPID"
[ -n "$PARAMS" ] && SRCDS_PARAMS="$SRCDS_PARAMS $PARAMS"

# call srcds directly
LD_LIBRARY_PATH=".:linux64:bin/linux64:$LD_LIBRARY_PATH"
HOME=/opt/gmod/cache/steamclient_cache
export LD_LIBRARY_PATH HOME

# shellcheck disable=SC2086
exec ./bin/linux64/srcds \
    -game garrymod -strictportbind \
    $SRCDS_PARAMS
