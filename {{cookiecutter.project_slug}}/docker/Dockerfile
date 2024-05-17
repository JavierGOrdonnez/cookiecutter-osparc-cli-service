# Docker base image, change if needed
FROM ubuntu:20.04 AS base

# ------------------------------------------------------------------------------------
# oSPARC compatibility, do not modify
# simcore-user uid=8004(${SC_USER_NAME}) gid=8004(${SC_USER_NAME}) groups=8004(${SC_USER_NAME})
ENV SC_USER_ID 8004
ENV SC_USER_NAME scu
RUN adduser --uid ${SC_USER_ID} --disabled-password --gecos "" --shell /bin/sh --home /home/${SC_USER_NAME} ${SC_USER_NAME}
# ------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------
# TODO: add additional system packages if needed, jq and zip are required
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
 jq \
 zip \
 && rm -rf /var/lib/apt/lists/*
# ------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------
# TODO: add here instructions to install other custom sofware if necessary
# E.g. 
# WORKDIR /home/
# RUN git clone https://github.com/spinalcordtoolbox/spinalcordtoolbox.git && \
#     cd spinalcordtoolbox && \
#     git checkout -b release 6e75cd8a4b33182b1261e92ad3a4698819e76067 && \
#     ./install_sct -y -i  
# ENV PATH="/home/spinalcordtoolbox/bin/:${PATH}"
# -------------------------------------------------------------------------------------

# --------------------------------- Final setup  --------------------------------------
# Do not modify

ENV INPUT_FOLDER="/input" \
    OUTPUT_FOLDER="/output"

WORKDIR /home/${SC_USER_NAME}


# copy docker bootup scripts
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} docker/*.sh docker/

# copy simcore service cli
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} service.cli/ service.cli/
# necessary to be able to call run directly without sh in front
ENV PATH="/home/${SC_USER_NAME}/service.cli:${PATH}"


ENTRYPOINT [ "/bin/sh", "docker/entrypoint.sh", "/bin/sh", "-c" ]
CMD ["run"]
# -------------------------------------------------------------------------------------