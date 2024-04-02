#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0

label: Cell Nuclei Segmentation

doc: |-
  This WIPP plugin segments cell nuclei using U-Net in Tensorflow.
  https://github.com/PolusAI/image-tools/tree/master/segmentation/polus-cell-nuclei-segmentation-plugin

requirements:
  DockerRequirement:
    dockerPull: polusai/kaggle-nuclei-segmentation-tool:0.1.5-dev
  EnvVarRequirement:
    envDef:
      HOME: /home/polusai
  # See https://www.commonwl.org/v1.0/CommandLineTool.html#InitialWorkDirRequirement
  InitialWorkDirRequirement:
    listing:
    - entry: $(inputs.outDir)
      writable: true  # Output directories must be writable
  InlineJavascriptRequirement: {}

hints:
  cwltool:CUDARequirement:
    cudaVersionMin: "11.4"
    cudaComputeCapabilityMin: "3.0"
    cudaDeviceCountMin: 1
    cudaDeviceCountMax: 1

inputs:
  inpDir:
    label: Path to input images
    doc: |-
      Path to input images
    type: Directory
    inputBinding:
      prefix: --inpDir

  outDir:
    label: Output image collection
    doc: |-
      Output image collection
    type: Directory
    inputBinding:
      prefix: --outDir

outputs:
  outDir:
    label: Output image collection
    doc: |-
      Output image collection
    type: Directory
    outputBinding:
      glob: $(inputs.outDir.basename)

$namespaces:
  edam: https://edamontology.org/
  cwltool: http://commonwl.org/cwltool#

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl

# manifest: https://raw.githubusercontent.com/PolusAI/image-tools/master/segmentation/polus-cell-nuclei-segmentation-plugin/plugin.json