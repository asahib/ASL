#!/bin/bash
maindir="/nafs/narr/asahib/ASL/ASL_nifti"
hcpdir="/nafs/narr/HCP_OUTPUT"
txtfile="/nafs/narr/asahib/ASL"


module unload fsl
module load fsl/6.0.1
cd ${maindir}


ALLSubjects=$(<$txtfile/Sublist_HC.txt)

for sub in $ALLSubjects
	do
		

	fslmerge -t ${maindir}/${sub}/${sub}_PA_AP_mergedspinecho ${maindir}/${sub}/${sub}_PCASLHR_SPINECHOFIELDMAP_PA.nii.gz ${maindir}/${sub}/${sub}_PCASLHR_SPINECHOFIELDMAP_AP.nii.gz

topup --imain=${maindir}/${sub}/${sub}_PA_AP_mergedspinecho.nii.gz --datain=${txtfile}/topup_params.txt --config=b02b0.cnf --out=${maindir}/${sub}/topup_results --fout=${maindir}/${sub}/my_field --iout=${maindir}/${sub}/my_unwarped_images

fslroi ${maindir}/${sub}/${sub}_MBPCASLHR_PA.nii.gz ${maindir}/${sub}/${sub}_MO_2_end 88 -1

fslroi ${maindir}/${sub}/${sub}_MBPCASLHR_PA.nii.gz ${maindir}/${sub}/${sub}_MBPCASL_trim4 0 86

applytopup --imain=${maindir}/${sub}/${sub}_MBPCASL_trim4.nii.gz --datain=${maindir}/topup_params.txt --inindex=1 --topup=${maindir}/${sub}/topup_results --out=${maindir}/${sub}/${sub}_topup_MBPCASL --method=jac

applytopup --imain=${maindir}/${sub}/${sub}_MO_2_end.nii.gz --datain=${maindir}/topup_params.txt --inindex=1 --topup=${maindir}/${sub}/topup_results --out=${maindir}/${sub}/${sub}_topup_2_MO --method=jac


mcflirt -in ${maindir}/${sub}/${sub}_topup_MBPCASL.nii.gz -out ${maindir}/${sub}/${sub}_MC_MBPCASL -plots

asl_file --data=${maindir}/${sub}/${sub}_MC_MBPCASL.nii.gz --ntis=1 --iaf=tc --diff --out=${maindir}/${sub}/${sub}_asldiffdata_TP_MC --mean=${maindir}/${sub}/${sub}_asldiffdata_TP_MC_mean

asl_file --data=${maindir}/${sub}/${sub}_MC_MBPCASL.nii.gz --ntis=5 --iaf=tc --diff --ibf=tis --rpts=6,6,6,10,15 --out=${maindir}/${sub}/${sub}_asldiffdata_TP_MC --mean=${maindir}/${sub}/${sub}_asldiffdata_TP_MC_5delays

fsl_anat -i ${hcpdir}/${sub}/MNINonLinear/T1w.nii.gz -o ${maindir}/${sub}/T1w --clobber

oxford_asl -i ${maindir}/${sub}/${sub}_topup_MC.nii.gz -o ${maindir}/${sub}/oxasl_MD_F --casl --iaf=tc --ibf=tis --tis=1.7,2.2,2.7,3.2,3.7 --rpts=6,6,6,10,15 --bolus=1.5 --spatial=off --mc --fslanat=${maindir}/${sub}/T1w.anat/ -c ${maindir}/${sub}/${sub}_topup_2_MO.nii.gz --tr=8 --slicedt=0.059 --sliceband=6 --fixbolus --cmethod=voxel --pvcorr

done
