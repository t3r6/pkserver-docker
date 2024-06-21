#!/bin/sh

export PKS_BINARY_PATH="${PKS_DIR}/Bin/${PKS_BINARY}"
export PKS_BINARY_TEMP="/tmp/PKS_temp"

hack_lscripts()
{
    bbe -e 's/LScripts.pak/'"${PKS_LSCRIPTS}"'/' "${PKS_BINARY_PATH}" > "${PKS_BINARY_TEMP}"
    mv "${PKS_BINARY_TEMP}" "${PKS_BINARY_PATH}"
    bbe -e 's/lscripts.pak/'"${PKS_LSCRIPTS}"'/' "${PKS_BINARY_PATH}" > "${PKS_BINARY_TEMP}"
    mv "${PKS_BINARY_TEMP}" "${PKS_BINARY_PATH}"
    chmod 755 "${PKS_BINARY_PATH}"
}

hack_cfg()
{
    bbe -e 's/config.ini/'"${PKS_CFG}"'/' "${PKS_BINARY_PATH}" > "${PKS_BINARY_TEMP}"
    mv "${PKS_BINARY_TEMP}" "${PKS_BINARY_PATH}"
    chmod 755 "${PKS_BINARY_PATH}"
}

if [ -n "${PKS_LSCRIPTS}" ] && [ "${PKS_LSCRIPTS}" != "LScripts.pak" ] && [ "${PKS_LSCRIPTS}" != "lscripts.pak" ] 
then
    hack_lscripts
fi

if [ -n "${PKS_CFG}" ] && [ "${PKS_CFG}" != "config.ini" ]
then
    hack_cfg
fi

exec "${PKS_BINARY_PATH}" "$@"