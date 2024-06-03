#!/bin/bash

set -x
set -e

export RUST_LOG="info"

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
OUTDIR_BASE="${SCRIPTPATH}/../outputs"

echo $SCRIPT
echo $SCRIPTPATH
echo $OUTDIR_BASE

mkdir -p $OUTDIR_BASE

SAGE_EXE="${SCRIPTPATH}/../software/sage"
# IONMESH_EXE="${SCRIPTPATH}/../software/ionmesh"
IONMESH_EXE="${SCRIPTPATH}/../software/ionmesh_nochimera"
HUMAN_FASTA="${SCRIPTPATH}/../data/UP000005640_9606_crap_prtc.fasta"

# Data files
HELA_PRTC_22_DIA_FLATTENED="${SCRIPTPATH}/../data/230510_PRTC_12.mzml"
HELA_PRTC_22_DIA_RAW="${SCRIPTPATH}/../data/230510_PRTC_12.d"
HELA_PRTC_22_DDA_RAW="${SCRIPTPATH}/../data/240524_PRTC_22min_DDA.d"

mkdir -p ${OUTDIR_BASE}/PRTC_sage_wide_dia_mzml
(time (
    $SAGE_EXE \
    --output_directory "${OUTDIR_BASE}/PRTC_sage_wide_dia_mzml" \
    --fasta $HUMAN_FASTA \
    --parquet "${SCRIPTPATH}/../configs/sage_wide_human.json" \
    $HELA_PRTC_22_DIA_FLATTENED
)) 2>&1 | tee "${OUTDIR_BASE}/PRTC_sage_wide_dia_mzml/PRTC_sage_wide_dia.log"

mkdir -p ${OUTDIR_BASE}/PRTC_sage_wide_dda
(time (
    $SAGE_EXE \
    --output_directory "${OUTDIR_BASE}/PRTC_sage_wide_dda" \
    --fasta $HUMAN_FASTA \
    --parquet "${SCRIPTPATH}/../configs/sage_wide_human.json" \
    $HELA_PRTC_22_DDA_RAW
)) 2>&1 | tee "${OUTDIR_BASE}/PRTC_sage_wide_dda/PRTC_sage_wide_dda.log"

mkdir -p ${OUTDIR_BASE}/PRTC_ionmesh_wide_dia
(time (
    $IONMESH_EXE \
    --output-dir "${OUTDIR_BASE}/PRTC_ionmesh_wide_dia" \
    --config "${SCRIPTPATH}/../configs/default_ionmesh_config.toml" \
    $HELA_PRTC_22_DIA_RAW
)) 2>&1 | tee "${OUTDIR_BASE}/PRTC_ionmesh_wide_dia/PRTC_ionmesh_wide_dia.log"


IONMESH_NMIAA_CONFIG="${SCRIPTPATH}/../configs/variable_nmiaa_ionmesh_config.toml"
SAGE_NMIAA_CONFIG="${SCRIPTPATH}/../configs/sage_wide_human_nmiaa.json"

for x in 231121_RH30_NMIAA_E1_DDA.d 231121_RH30_NMIAA_E1_DDA.mzml \
    231121_RH30_NMIAA_E1_DIA.d 231121_RH30_NMIAA_E1_DIA.mzml \
    231121_RH30_NMIAA_E6_DDA.d 231121_RH30_NMIAA_E6_DDA.mzml \
    231121_RH30_NMIAA_E6_DIA.d 231121_RH30_NMIAA_E6_DIA.mzml ; do

    filestem=$(basename $(basename $x .d) .mzml)

    if [[ $x == *.d ]]; then
        if [[ $x == *DIA.d ]]; then

            mkdir -p "${OUTDIR_BASE}/NMIAA_ionmesh_wide_dia/${filestem}"
            (time (
                $IONMESH_EXE \
                --output-dir "${OUTDIR_BASE}/NMIAA_ionmesh_wide_dia/${filestem}" \
                --config "${IONMESH_NMIAA_CONFIG}" \
                "${SCRIPTPATH}/../data/$x"
            )) 2>&1 | tee "${OUTDIR_BASE}/NMIAA_ionmesh_wide_dia/${filestem}.log"
        else
            mkdir -p "${OUTDIR_BASE}/NMIAA_sage_wide_dda/${filestem}"
            (time (
                $SAGE_EXE \
                --output_directory "${OUTDIR_BASE}/NMIAA_sage_wide_dda/${filestem}" \
                --fasta $HUMAN_FASTA \
                --parquet "${SAGE_NMIAA_CONFIG}" \
                "${SCRIPTPATH}/../data/$x"
            )) 2>&1 | tee "${OUTDIR_BASE}/NMIAA_sage_wide_dda/${filestem}.log"
        fi
    else
        if [[ $x == *DIA.mzml ]]; then
            target_dir="${OUTDIR_BASE}/NMIAA_sage_wide_dia_mzml/${filestem}"
        else
            target_dir="${OUTDIR_BASE}/NMIAA_sage_wide_dda_mzml/${filestem}"
        fi
        mkdir -p "${target_dir}"
        (time (
            $SAGE_EXE \
            --output_directory "${target_dir}" \
            --fasta $HUMAN_FASTA \
            --parquet "${SAGE_NMIAA_CONFIG}" \
            "${SCRIPTPATH}/../data/$x"
        )) 2>&1 | tee "${target_dir}/${filestem}.log"
    fi
done