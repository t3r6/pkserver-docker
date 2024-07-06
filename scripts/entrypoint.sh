#!/bin/sh

export PKS_BINARY_PATH="${PKS_DIR}/Bin/${PKS_BINARY}"
export PKS_CFG_DEFAULT_PATH="${PKS_DIR}/Bin/config.ini"
export PKS_BINARY_TEMP="/tmp/pkserver_temp"
export PKS_CONFIG_TEMP="/tmp/config_temp"

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

modify_cfg()
{
    awk 'BEGIN{for(v in ENVIRON) if(v ~ /^CFG_/) print v}' | while read -r cfg_env
        do
            prefix="CFG_"
            cfg_parameter="${cfg_env#"$prefix"}"
            cfg_env_val="$(eval echo \$${cfg_env})"
            if grep -iq "${cfg_parameter}.*{" "${PKS_CFG_DEFAULT_PATH}"
            then
                # This script modifies the Cfg parameter value in curly braces
                awk -v param="Cfg.${cfg_parameter}" -v env="${cfg_env_val}" '
                    BEGIN{
                        FS="=";
                        OFS=" = "
                    }
                    {
                        gsub(/^[ \t]+|[ \t]+$/, "", $1);
                        if(tolower($1) == tolower(param)) {
                            $2 = "" env ""
                        }
                    }
                    1' "${PKS_CFG_DEFAULT_PATH}" > "${PKS_CONFIG_TEMP}"
                mv "${PKS_CONFIG_TEMP}" "${PKS_CFG_DEFAULT_PATH}"
            else
                # This script modifies the Cfg parameter value which is empty or within double quotes
                awk -v param="Cfg.${cfg_parameter}" -v env="${cfg_env_val}" '
                    BEGIN{
                        FS=OFS=" = "
                    }
                    tolower($1) == tolower(param) {
                        $2 = (substr($2, 1, 1) == "\"" ? "\"" env "\"" : env)
                    }
                    1' "${PKS_CFG_DEFAULT_PATH}" > "${PKS_CONFIG_TEMP}"
                mv "${PKS_CONFIG_TEMP}" "${PKS_CFG_DEFAULT_PATH}"
            fi
        done
}

if [ -n "${PKS_LSCRIPTS}" ] && [ "${PKS_LSCRIPTS}" != "LScripts.pak" ] && [ "${PKS_LSCRIPTS}" != "lscripts.pak" ] 
then
    hack_lscripts
fi

# CFG Environment variables only work with the default config.ini
if [ -n "${PKS_CFG}" ] && [ "${PKS_CFG}" != "config.ini" ]
then
    hack_cfg
else
    modify_cfg
fi

exec "${PKS_BINARY_PATH}" "$@"