maindir="/nafs/narr/HCP_OUTPUT"
hcpdir="/nafs/narr/HCP_OUTPUT"
txtfile="/nafs/narr/asahib/ASL/KET1_KET4/HCvsMDD"


module unload fsl
module load fsl/6.0.1
module unload workbench
module load workbench/1.3.2
#cd ${maindir}


ALLSubjects=$(<$txtfile/HCvsMDD.txt)

for sub in $ALLSubjects
	do

		roiVolume="${hcpdir}/${sub}/MNINonLinear/Results/task-rest_acq-PA_run-01/RibbonVolumeToSurfaceMapping/goodvoxels.nii.gz"
		Flag="-fix-zeros"
      		VolROI="-volume-roi $roiVolume"
		volumeIn="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/perfusion_calib.nii.gz"
		currentParcel="${hcpdir}/${sub}/MNINonLinear/ROIs/ROIs.2.nii.gz"
		newParcel="${hcpdir}/${sub}/MNINonLinear/ROIs/Atlas_ROIs.2.nii.gz"
		kernel="1"
		volumeOut="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}_AtlasSubcortical.nii.gz"
		wb_command -volume-parcel-resampling $volumeIn $currentParcel $newParcel $kernel $volumeOut ${Flag}
		for Hemisphere in L R ; do
			volume="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/perfusion_calib.nii.gz"
			surface="${hcpdir}/${sub}/MNINonLinear/Native/sub-${sub}.${Hemisphere}.midthickness.native.surf.gii"
			metricOut="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}.${Hemisphere}.native.func.gii"
			ribbonInner="${hcpdir}/${sub}/MNINonLinear/Native/sub-${sub}.${Hemisphere}.white.native.surf.gii"
			ribbonOutter="${hcpdir}/${sub}/MNINonLinear/Native/sub-${sub}.${Hemisphere}.pial.native.surf.gii"
			wb_command -volume-to-surface-mapping $volume $surface $metricOut -ribbon-constrained $ribbonInner $ribbonOutter ${VolROI}
			metric="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}.${Hemisphere}.native.func.gii"
			distance="20"
			metricOut="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}.${Hemisphere}.native.func.gii"
			wb_command -metric-dilate $metric $surface $distance $metricOut -nearest

			metric="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}.${Hemisphere}.native.func.gii"
  			mask="${hcpdir}/${sub}/MNINonLinear/Native/sub-${sub}.${Hemisphere}.roi.native.shape.gii"
   			metricOut="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}.${Hemisphere}.native.func.gii"
   			wb_command -metric-mask $metric $mask $metricOut

			metricIn="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}.${Hemisphere}.native.func.gii"
			currentSphere="${hcpdir}/${sub}/MNINonLinear/Native/sub-${sub}.${Hemisphere}.sphere.reg.reg_LR.native.surf.gii"
			newSphere="${hcpdir}/${sub}/MNINonLinear/fsaverage_LR32k/sub-${sub}.${Hemisphere}.sphere.32k_fs_LR.surf.gii"
			method="ADAP_BARY_AREA"
			metricOut="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}-FS.${Hemisphere}.32k_fs_LR.func.gii"
			currentArea="${hcpdir}/${sub}/MNINonLinear/Native/sub-${sub}.${Hemisphere}.midthickness.native.surf.gii"
			newArea="${hcpdir}/${sub}/MNINonLinear/fsaverage_LR32k/sub-${sub}.${Hemisphere}.midthickness.32k_fs_LR.surf.gii"
			roiMetric="${hcpdir}/${sub}/MNINonLinear/Native/sub-${sub}.${Hemisphere}.roi.native.shape.gii"
			wb_command -metric-resample $metricIn $currentSphere $newSphere $method $metricOut -area-surfs $currentArea $newArea -current-roi $roiMetric
			metric="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}-FS.${Hemisphere}.32k_fs_LR.func.gii"
			mask="${hcpdir}/${sub}/MNINonLinear/fsaverage_LR32k/sub-${sub}.${Hemisphere}.atlasroi.32k_fs_LR.shape.gii"
			metricOut="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}-FS.${Hemisphere}.32k_fs_LR.func.gii"
			wb_command -metric-mask $metric $mask $metricOut
			surface="${hcpdir}/${sub}/MNINonLinear/fsaverage_LR32k/sub-${sub}.${Hemisphere}.midthickness.32k_fs_LR.surf.gii"
			metricIn="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}-FS.${Hemisphere}.32k_fs_LR.func.gii"
			smoothingKernel=`echo "5 / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
			metricOut="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}-FS_fwhm5.${Hemisphere}.32k_fs_LR.func.gii"
			roiMetric="${hcpdir}/${sub}/MNINonLinear/fsaverage_LR32k/sub-${sub}.${Hemisphere}.atlasroi.32k_fs_LR.shape.gii"
			wb_command -metric-smoothing $surface $metricIn $smoothingKernel $metricOut -roi $roiMetric
		done

	ciftiOut="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}_AtlasFS_fwhm5_perfusion_calib.dscalar.nii"
	volumeData="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}_AtlasSubcortical.nii.gz"
	labelVolume="${hcpdir}/${sub}/MNINonLinear/ROIs/Atlas_ROIs.2.nii.gz"
	lMetric="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}-FS_fwhm5.L.32k_fs_LR.func.gii"
	lRoiMetric="${hcpdir}/${sub}/MNINonLinear/fsaverage_LR32k/sub-${sub}.L.atlasroi.32k_fs_LR.shape.gii"
	
	rMetric="${maindir}/${sub}/ASL/oxasl_MD_F/std_space/pvcorr/${sub}-FS_fwhm5.R.32k_fs_LR.func.gii"
      
	rRoiMetric="${hcpdir}/${sub}/MNINonLinear/fsaverage_LR32k/sub-${sub}.R.atlasroi.32k_fs_LR.shape.gii"
	wb_command -cifti-create-dense-scalar $ciftiOut -volume $volumeData $labelVolume -left-metric $lMetric -roi-left $lRoiMetric -right-metric $rMetric -roi-right $rRoiMetric
done
			













