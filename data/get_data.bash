#!/bin/bash

set -x
set -e

export DOCKER_DEFAULT_PLATFORM=linux/amd64

# PRTC data (commercial hela + PRTC)
if [ ! -e 230510_PRTC_12.mzml ]; then
    aws s3 cp s3://data-pipeline-raw-bucket/240513_Anborn_SET9_REP1/230510_PRTC_12.d.tar .
    tar -xf 230510_PRTC_12.d.tar
    mv 230510_PRTC_12*.d 230510_PRTC_12.d
    docker run --rm -it -v $PWD:/data mfreitas/tdf2mzml tdf2mzml.py -i /data/230510_PRTC_12.d
fi

# DDA PRTC
#  s3://data-pipeline-raw-bucket/240524_PRTC_22min_DDA/240524_PRTC_22min_DDA.d.tar
if [ ! -e 240524_PRTC_22min_DDA.mzml ]; then
    aws s3 cp s3://data-pipeline-raw-bucket/240524_PRTC_22min_DDA/240524_PRTC_22min_DDA.d.tar .
    tar -xf 240524_PRTC_22min_DDA.d.tar
    rm -rf 240524_PRTC_22min_DDA.d
    mv 240524_PRTC_22min_DDA*.d 240524_PRTC_22min_DDA.d
    docker run --rm -it -v $PWD:/data mfreitas/tdf2mzml tdf2mzml.py -i /data/240524_PRTC_22min_DDA.d
fi

# NMIAA samples
# 231121_RH30_NMIAA/231121_RH30_NMIAA_E1_DIA.d.tar
# 231121_RH30_NMIAA/231121_RH30_NMIAA_E6_DIA.d.tar
# 231121_RH30_NMIAA/231121_RH30_NMIAA_E1_DDA.d.tar
# 231121_RH30_NMIAA/231121_RH30_NMIAA_E6_DDA.d.tar
for i in 1 6; do
    for d in DIA DDA; do
        if [ ! -e 231121_RH30_NMIAA_E${i}_${d}.mzml ]; then
            if [ ! -e 231121_RH30_NMIAA_E${i}_${d}.d ]; then
                aws s3 cp s3://data-pipeline-raw-bucket/231121_RH30_NMIAA/231121_RH30_NMIAA_E${i}_${d}.d.tar .
                tar -xf 231121_RH30_NMIAA_E${i}_${d}.d.tar
                mv 231121_RH30_NMIAA_E${i}_${d}*.d 231121_RH30_NMIAA_E${i}_${d}.d
            fi
            docker run --rm -it -v $PWD:/data mfreitas/tdf2mzml tdf2mzml.py -i /data/231121_RH30_NMIAA_E${i}_${d}.d
        fi
    done
done

# if [ ! -f 231121_RH30_NMIAA_E1_DDA.mzml ]; then
#     aws s3 cp s3://data-pipeline-raw-bucket/231121_RH30_NMIAA/231121_RH30_NMIAA_E1_DDA.d.tar .
#     tar -xf 231121_RH30_NMIAA_E1_DDA.d.tar
#     mv 231121_RH30_NMIAA_E1_DDA*.d 231121_RH30_NMIAA_E1_DDA.d
# fi


# Phospho data
if [ ! -e 202106022_TIMS03_EVO03_HeLa_mannlab_phospho.mzml ]; then
    wget --continue https://ftp.pride.ebi.ac.uk/pride/data/archive/2022/08/PXD034128/Phospho_optimal_diaPASEF.zip
    unzip Phospho_optimal_diaPASEF.zip
    mv 202106022_TIMS03_EVO03_PaSk_SA_HeLa_Phospho_100ug_EGF_PhosphoLiDIA_S1-C1_1_25980.d 202106022_TIMS03_EVO03_HeLa_mannlab_phospho.d
    docker run --rm -it -v $PWD:/data mfreitas/tdf2mzml tdf2mzml.py -i /data/202106022_TIMS03_EVO03_HeLa_mannlab_phospho.d
fi

## Script used in GCP to download the data
# set -x
# set -e
# sudo apt-get install unzip
# 
# # for x in 7 10 15 30 60; do ... 
# # 15 min is broken ...
# # 30 min is also broken ...
# for x in 7 10 30 60; do
#     if [ ! -e ${x}min.zip ]; then
#         wget --continue https://ftp.pride.ebi.ac.uk/pride/data/archive/2022/10/PXD033904/${x}min.zip
#         unzip ${x}min.zip && gcloud storage cp ${x}min.zip gs://raw_ms_data/PXD033904/${x}min.zip && rm -rf ${x}min && rm -rf ${x}min.zip
#     fi
# done

if [ !-e ];
    # This is SOOOOO SLOW ... So I downloaded it with GCP in europe and uploaded to GS.
    # wget --continue https://ftp.pride.ebi.ac.uk/pride/data/archive/2022/10/PXD033904/30min.zip
    # gcloud storage cp 30min.zip gs://raw_ms_data/PXD033904/30min.zip
    # rm -rf 30min.zip

    # for x in 7 10 15 30 60; do
    # A LOT of the files seem to be broken ...
    for x in 7 10; do
        gcloud storage cp gs://raw_ms_data/PXD033904/${x}min.zip
        unzip ${x}min.zip
    done

done


# 231009_THP1_1k_DDA_Test/231009_hela_44min_2_5_DDA.d.tar

# Fasta database
if [ ! -e UP000005640_9606_crap_prtc.fasta ]; then
    wget --continue https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
    gunzip UP000005640_9606.fasta.gz

    wget --continue https://raw.githubusercontent.com/jspaezp/proteomics_datasamples/main/fasta/crap.fasta
    wget --continue https://panoramaweb.org/home/wiki-download.view?entityId=2f1ae85c-bbe8-1039-b76f-fea6ddf5767a&name=prtc.fasta -O prtc.fasta

    cat UP000005640_9606.fasta crap.fasta prtc.fasta > UP000005640_9606_crap_prtc.fasta
fi

    wget --continue https://ftp.pride.ebi.ac.uk/pride/data/archive/2022/10/PXD033904/${x}min.zip
    gcloud storage cp ${x}min.zip gs://raw_ms_data/PXD033904/${x}min.zip
    rm -rf ${x}min.zip
done