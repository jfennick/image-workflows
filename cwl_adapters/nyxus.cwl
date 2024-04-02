#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0

label: Nyxus

doc: |-
  Nyxus plugin uses parallel processing of Nyxus python package to extract nyxus features from intensity-label image data.
  https://github.com/PolusAI/nyxus
  NOT https://github.com/PolusAI/polus-plugins/tree/master/features/nyxus-plugin

requirements:
  DockerRequirement:
    dockerPull: polusai/nyxus:0.7.5
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

# https://github.com/PolusAI/nyxus?tab=readme-ov-file#command-line-usage
# TODO: implement all CLI options

inputs:
# NOT inpDir
  intDir:
    label: Input image directory
    doc: |-
      Input image directory
    type: Directory
    inputBinding:
      prefix: --intDir

  segDir:
    label: Input label image directory
    doc: |-
      Input label image directory
    type: Directory
    inputBinding:
      prefix: --segDir

  # intPattern:
  #   label: Filepattern to parse intensity images
  #   doc: |-
  #     Filepattern to parse intensity images
  #   type: string
  #   inputBinding:
  #     prefix: --intPattern

  # segPattern:
  #   label: Filepattern to parse label images
  #   doc: |-
  #     Filepattern to parse label images
  #   type: string
  #   inputBinding:
  #     prefix: --segPattern

  features:
    label: nyxus features
    doc: |-
      nyxus features
    type: string?  # optional array of strings?
    inputBinding:
      prefix: --features

# NOT fileExtension
  outputType:
    label: Output file format
    doc: |-
      Output file format
    type: string
    inputBinding:
      prefix: --outputType
    default: singlecsv  # enum: separatecsv, singlecsv, arrowipc, orparquet

  # neighborDist:
  #   label: Distance between two neighbor objects
  #   doc: |-
  #     Distance between two neighbor objects
  #   type: float?
  #   inputBinding:
  #     prefix: --neighborDist

  # pixelPerMicron:
  #   label: Pixel Size in micrometer
  #   doc: |-
  #     Pixel Size in micrometer
  #   type: float?
  #   inputBinding:
  #     prefix: --pixelPerMicron

  singleRoi:
    label: Consider intensity image as single roi and ignoring segmentation mask
    doc: |-
      Consider intensity image as single roi and ignoring segmentation mask
    type: boolean?
    inputBinding:
      prefix: --singleRoi

  useGpu:
    label: Consider intensity image as single roi and ignoring segmentation mask
    doc: |-
      Consider intensity image as single roi and ignoring segmentation mask
    type: boolean?
    inputBinding:
      prefix: --useGpu=true

  fpimgmax:
    label: determines scaling
    doc: |-
      determines scaling
    type: float?
    inputBinding:
      prefix: --fpimgmax

  outDir:
    label: Output collection
    doc: |-
      Output collection
    type: Directory
    inputBinding:
      prefix: --outDir

outputs:
  outDir:
    label: Output collection
    doc: |-
      Output collection
    type: Directory
    outputBinding:
      glob: $(inputs.outDir.basename)

$namespaces:
  edam: https://edamontology.org/
  cwltool: http://commonwl.org/cwltool#

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl

# manifest: https://raw.githubusercontent.com/PolusAI/nyxus/main/plugin.json
# NOT https://raw.githubusercontent.com/PolusAI/polus-plugins/master/features/nyxus-plugin/plugin.json