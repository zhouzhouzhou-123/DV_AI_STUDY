#!/bin/sh

cd ${BRUN_TOP_DIR}/../../sim

# -------------------  print path & file info ---------------- #
echo -n "TOP_DIR = "
echo ${BRUN_TOP_DIR}
echo -n "current directory = "
pwd

# -------------------  print TESTNAME & SEED---------------- #
echo -n "TESTNAME = "
echo ${BRUN_TEST_NAME}
echo -n "seed = "
echo ${BRUN_SV_SEED}

# -------------------  command & define handling ---------------- #
# command from vsif : default is m run
COMMAND="run"

# define from vsif
USER_DEFINE="define="
# add FSDB_DUMP_OFF to disable fsdb dump in regression
USER_DEFINE+="FSDB_DUMP_OFF"
# add SIM_ARGS from VSIF
USER_DEFINE+="+${BRUN_SIM_ARGS}"

# arguments
if [ $# -eq 2 ]; then
    COMMAND=$1
    USER_DEFINE+="+$2"
elif [ $# -eq 1 ]; then
    if [ "$1" = "comp" ] || [ "$1" = "nocomp_run" ] || [ "$1" = "run" ]; then
        COMMAND=$1
    else
        USER_DEFINE+="+$1"
    fi
fi

# add NO_COVERAGE in postsim
if [[ ${USER_DEFINE} =~ "POST_SIM_ON" ]]; then
    USER_DEFINE+="+NO_COVERAGE"
fi
# print all defines
echo -n "simulation arguments from VSIF : "
echo $USER_DEFINE

# -------------------  run testcase by calling m---------------- #
COMMAND_TO_BE_RUN="\
    m $COMMAND \
    ${BRUN_TEST_NAME} \
    ${BRUN_SV_SEED} \
    ${USER_DEFINE} \
"
echo -n "command to be run= "
echo $COMMAND_TO_BE_RUN
$COMMAND_TO_BE_RUN

# -------------------  link coverage database ---------------- #
if [ ! -d "../coverage/coverage.vdb" ]
then
    mkdir ../coverage/coverage.vdb
fi

vdb_src=$(find "${BRUN_RUN_DIR}" -maxdepth 1 -name "*.vdb" -print -quit)
if [ -n "$vdb_src" ]
then
    echo "link covarage VDB..."
    ln -s "$vdb_src" ../coverage/coverage.vdb/${BRUN_TEST_NAME}_${BRUN_SV_SEED}.vdb
else
    echo "no covarage VDB founded..."
fi
