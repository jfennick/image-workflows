from pathlib import Path
from typing import Any

from wic.api.pythonapi import Step, Workflow

def nuclear_segmentation() -> Workflow:
    filename = 'nuclear_segmentation_py'
    workflow = Workflow([], filename)

    bbbcdownload = Step(clt_path='../image-workflows/cwl_adapters/bbbcdownload.cwl')
    # We can inline the inputs to each step individually.
    bbbcdownload.name = 'BBBC039'
    bbbcdownload.outDir = Path('bbbcdownload.outDir')

    subdirectory = Step(clt_path='../workflow-inference-compiler/cwl_adapters/subdirectory.cwl')
    subdirectory.directory = bbbcdownload.outDir
    subdirectory.glob_pattern = 'bbbcdownload.outDir/BBBC/BBBC039/raw/Images/images/'

    filerenaming = Step(clt_path='../image-workflows/cwl_adapters/file-renaming.cwl')
    filerenaming.filePattern = workflow.file_pattern
    filerenaming.inpDir = subdirectory.subdirectory
    filerenaming.outDir = Path('file-renaming.outDir')
    filerenaming.outFilePattern = workflow.out_file_pattern

    omeconverter = Step(clt_path='../image-workflows/cwl_adapters/ome-converter.cwl')
    omeconverter.inpDir = filerenaming.outDir
    omeconverter.filePattern = workflow.out_file_pattern
    omeconverter.fileExtension = '.ome.tif'
    omeconverter.outDir = Path('omeconverter.outDir')

    # Alternatively, we can also "configure" the inputs for each Step by
    # passing them as inputs to the (sub)-workflow.
    estimate_flatfield = Step(clt_path='../image-workflows/cwl_adapters/basic-flatfield-estimation.cwl')
    estimate_flatfield.inpDir = omeconverter.outDir
    estimate_flatfield.filePattern = workflow.image_pattern
    estimate_flatfield.groupBy = workflow.group_by
    estimate_flatfield.getDarkfield = True
    estimate_flatfield.outDir = Path("estimate_flatfield.outDir")

    apply_flatfield = Step(clt_path='../image-workflows/cwl_adapters/apply-flatfield.cwl')
    apply_flatfield.imgDir = omeconverter.outDir
    apply_flatfield.imgPattern = workflow.image_pattern
    apply_flatfield.ffDir = estimate_flatfield.outDir
    apply_flatfield.ffPattern = workflow.ff_pattern
    apply_flatfield.dfPattern = workflow.df_pattern
    apply_flatfield.outDir = Path("apply_flatfield.outDir")

    kaggle_nuclei_segmentation = Step(clt_path='../image-workflows/cwl_adapters/kaggle_nuclei_segmentation.cwl')
    kaggle_nuclei_segmentation.inpDir = apply_flatfield.outDir
    kaggle_nuclei_segmentation.outDir = Path("kaggle_nuclei_segmentation.outDir")

    ftl_plugin = Step(clt_path='../image-workflows/cwl_adapters/ftl-label.cwl')
    ftl_plugin.inpDir = kaggle_nuclei_segmentation.outDir
    ftl_plugin.connectivity = 1
    ftl_plugin.binarizationThreshold = 0.5
    ftl_plugin.outDir = Path("ftl_plugin.outDir")

    workflow.setattr_means_output_var()
    workflow.outDir_apply_flatfield = apply_flatfield.outDir
    workflow.outDir_ftl_plugin = ftl_plugin.outDir
    workflow.setattr_means_input_val()

    steps = [bbbcdownload,
             subdirectory,
             filerenaming,
             omeconverter,
             estimate_flatfield,
             apply_flatfield,
             kaggle_nuclei_segmentation,
             ftl_plugin]
    for step in steps:
        workflow.append(step)
    return workflow


def feature_extraction() -> Workflow:
    filename = 'feat_extract_py'
    workflow = Workflow([], filename)

    subworkflow = nuclear_segmentation()
    # Now we can use the subworkflow as a reusable building block.
    # We do NOT have to copy & paste the individual steps over and over again!

    # Version 0.7.5 FYI
    nyxus = Step(clt_path='../image-workflows/cwl_adapters/nyxus.cwl')
    # NOTE: NOT inpDir
    # nyxus.intDir = subworkflow.steps[5].outDir  # apply_flatfield
    # nyxus.segDir = subworkflow.steps[6].outDir  # ftl_plugin
    nyxus.intDir = subworkflow.outDir_apply_flatfield
    nyxus.segDir = subworkflow.outDir_ftl_plugin
    nyxus.features = config['features']
    nyxus.fpimgmax = float(2**16)
    nyxus.outputType = "singlecsv"
    nyxus.useGpu = True
    nyxus.outDir =  Path("nyxus.outDir")

    steps = [subworkflow,
             nyxus]
    for step in steps:
        workflow.append(step)

    return workflow

JSON = dict[str, Any]

def configure_workflow(workflow: Workflow, configuration: JSON) -> None:
    # With subworkflows, configuration comes for free!
    for name, value in configuration.items():
        # print('name, value', name, value)
        setattr(workflow, name, value)
        # print('getattr(workflow, name)', getattr(workflow, name).value)

config: JSON = {
    "name": "BBBC039",
    "file_pattern": ".*_{row:c}{col:dd}_s{s:d}_w{channel:d}.*.tif", # subdirectory /.*/.*/.*/Images/(?P<directory>.*)/
    "out_file_pattern": "images_x{row:dd}_y{col:dd}_p{s:dd}_c{channel:d}.tif",
    "image_pattern": "images_x{x:dd}_y{y:dd}_p{p:dd}_c{c:d}.ome.tif",
    "seg_pattern": "images_x{x:dd}_y{y:dd}_p{p:dd}_c1.ome.tif",
    "ff_pattern": "images_x\\(00-15\\)_y\\(01-24\\)_p0\\(1-9\\)_c{c:d}_flatfield.ome.tif",
    "df_pattern": "images_x\\(00-15\\)_y\\(01-24\\)_p0\\(1-9\\)_c{c:d}_darkfield.ome.tif",
    "group_by": "c",
    "features": "*ALL_INTENSITY*,*ALL_MORPHOLOGY*",  # NOTE the asterisks
    "file_extension": "pandas"
}

# The CI assumes a top-level function with signature
# workflow() -> Workflow:
def workflow() -> Workflow:
    workflow = feature_extraction()
    configure_workflow(workflow.steps[0], config)
    return workflow

if __name__ == '__main__':
    workflow_ = workflow()
    # workflow_.write_ast_to_disk(Path('workflows/'))
    workflow_.run()  # .run() here, inside main
