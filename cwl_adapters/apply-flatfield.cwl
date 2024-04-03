#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0

label: Apply Flatfield

doc: |-
  This WIPP plugin applies a flatfield operation on every image in a collection.
  https://github.com/PolusAI/polus-plugins/tree/master/transforms/images/polus-apply-flatfield-plugin

requirements:
  DockerRequirement:
    dockerPull: polusai/apply-flatfield-plugin:2.0.0-dev10
  InitialWorkDirRequirement:
    listing:
    - entry: $(inputs.outDir)
      writable: true  # Output directories must be writable
  InlineJavascriptRequirement: {}

inputs:
  imgDir:
    label: Input image collection to be processed by this plugin
    doc: |-
      Input image collection to be processed by this plugin
    type: Directory
    inputBinding:
      prefix: --imgDir

  ffDir:
    label: Image collection containing flatfield and/or darkfield images
    doc: |-
      Image collection containing flatfield and/or darkfield images
    type: Directory
    inputBinding:
      prefix: --ffDir

# NOTE:   dfPattern in version 2.0.0-dev9
# NOTE: darkPattern in version 2.0.0-dev8 and 1.2.0
  dfPattern:
    label: Filename pattern used to match darkfield files to image files
    doc: |-
      Filename pattern used to match darkfield files to image files
    type: string?
    inputBinding:
      prefix: --dfPattern

# NOTE:     ffPattern in version 2.0.0-dev9
# NOTE: brightPattern in version 2.0.0-dev8 and 1.2.0

# https://github.com/PolusAI/image-tools/tree/master/transforms/images/polus-apply-flatfield-plugin#options
# NOTE:   flatPattern in README.md in master (no version information explicitly shown)
# i.e. The documentation does not correspond to *any* version!
  ffPattern:
    label: Filename pattern used to match flatfield files to image files
    doc: |-
      Filename pattern used to match flatfield files to image files
    type: string
    inputBinding:
      prefix: --ffPattern

  imgPattern:
    label: Filename pattern used to separate data and match with flatfield files
    doc: |-
      Filename pattern used to separate data and match with flatfield files
    type: string
    inputBinding:
      prefix: --imgPattern

  photoPattern:
    label: Filename pattern used to match photobleach files to image files
    doc: |-
      Filename pattern used to match photobleach files to image files
    type: string?
    inputBinding:
      prefix: --photoPattern

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

# manifest: https://raw.githubusercontent.com/PolusAI/polus-plugins/master/transforms/images/polus-apply-flatfield-plugin/plugin.json