#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: singularity
#baseCommand: echo

stdout: uc2.txt

inputs:
  calms: string
  tarms: string
  factordir: string
  workdir: string
  datadir: string
  container: string
  binddir: string
 
arguments: ["run", "-B", "$(inputs.binddir),$(inputs.factordir)", "$(inputs.container)", "calms=$(inputs.calms)", "tarms=$(inputs.tarms)", "factordir=$(inputs.factordir)", "workdir=$(inputs.workdir)", "datadir=$(inputs.datadir)"]
#arguments: ["===Running calcal===\ncalcal successfully done\nCalcal completed."]

outputs:
  out_file1:
    type: File
    streamable: true
    outputBinding:
      glob: uc2.txt
