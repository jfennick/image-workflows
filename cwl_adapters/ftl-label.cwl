#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0

label: Faster-Than-Light Label

doc: |-
  This plugin performs a transformation on binary images which, in a certain limiting case, can be thought of as segmentation.
  https://github.com/PolusAI/polus-plugins/tree/master/transforms/images/polus-ftl-label-plugin

requirements:
  DockerRequirement:
    dockerPull: polusai/ftl-label-plugin:0.3.12-dev5
  # See https://www.commonwl.org/v1.0/CommandLineTool.html#InitialWorkDirRequirement
  EnvVarRequirement:
    envDef:
      HOME: /home/polusai
  InitialWorkDirRequirement:
    listing:
    - entry: $(inputs.outDir)
      writable: true  # Output directories must be writable
  InlineJavascriptRequirement: {}

inputs:
  inpDir:
    label: Input image collection to be processed by this plugin
    doc: |-
      Input image collection to be processed by this plugin
    type: Directory
    inputBinding:
      prefix: --inpDir

  connectivity:
    label: City block connectivity
    doc: |-
      City block connectivity
    type: int
    inputBinding:
      prefix: --connectivity

  binarizationThreshold:
    label: ???
    doc: |-
      ???
    type: float
    inputBinding:
      prefix: --binarizationThreshold

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

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl

# manifest: https://raw.githubusercontent.com/PolusAI/polus-plugins/master/transforms/images/polus-ftl-label-plugin/plugin.json