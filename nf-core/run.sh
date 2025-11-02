#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate nf-core

# nextflowのバージョンを指定したいときは：
# export NXF_VER=23.10.1とかする
#
# 各ワークフローのデフォルトのコンフィグファイルは：
# ~/.nextflow/assets/nf-core/xxx/nextflow.config


# 共通の変数
GSE=GSE126390

# 1用の変数
CONFIG_FETCHNGS=data/fetchngs.config
EXP_LIST=data/SRR_Acc_List.${GSE}.csv

# 3用の変数
CONFIG_CHIPSEQ=data/chipseq.config
FDR=0.1
TRIM_NEXTSEQ=10
READ_LENGTH=50
#REF_VER=GRCh38
REF_VER=GRCm38

# 準備
RES_01=results/${GSE}/01
RES_02=results/${GSE}/02/
RES_03=results/${GSE}/03
mkdir -p logs/$GSE
mkdir -p $RES_01
mkdir -p $RES_02
mkdir -p $RES_03


# 1
# 注1：
# GEO番号からこのfetchngsへのinputファイルの作り方：
# （参考：https://nf-co.re/fetchngs/1.12.0/docs/usage/）
# 1. Search for your GEO accession on GEO
# 2. Click SRA Run Selector at the bottom of the GEO accession page
# 3. Select the desired samples in the SRA Run Selector and then download the Accession List
# 4. Rename the downloaded SRR_Acc_List.txt with a .csv extension
# 5. Use like "--input SRR_Acc_List.csv"
#
# 注2：
# --download_method sratools としないと、複数のfastqが一つにまとめられてしまうことがある？
# 参考： https://nf-co.re/fetchngs/usage#introduction

nextflow run nf-core/fetchngs \
  -c $CONFIG_FETCHNGS \
  -r 1.12.0 \
  -profile singularity \
  --input $EXP_LIST \
  --outdir $RES_01 \
  --download_method sratools \
  > logs/${GSE}/01.log 2>&1
  #-params-file xxx.yaml


# 2
# マニュアルで編集する
# effective genome sizeを計算する
# https://deeptools.readthedocs.io/en/develop/content/feature/effectiveGenomeSize.html#effective-genome-size


# 3
nextflow run nf-core/chipseq \
  -c $CONFIG_CHIPSEQ \
  -r 2.1.0 \
  -profile apptainer \
  --input ${RES_02}samplesheet.csv \
  --outdir $RES_03 \
  --genome $REF_VER \
  --narrow_peak \
  --macs_fdr $FDR \
  --read_length $READ_LENGTH \
  > logs/${GSE}/03.log 2>&1
  #--trim_nextseq $TRIM_NEXTSEQ \
  #--save_macs_pileup
