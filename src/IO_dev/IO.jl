
""" IN&OUT INTERFACE FOR SOLVER DEVELOPING \n
    {AnalysisDataStruct} = UI_dev.parsing_xml_file(xmlFileDir::string) 
          nothing        = UI_dev.Writing_ascii_file(inSimDataStruct::SimulationDataStruct,  fileName::string) \n
    __________________________________________________________________________________________________________ \n
"""
module IO_dev
    export 
        # PreProcessing
        Parsing_xml_file, 
        # PostProcessing
        Writing_ascii_file

    include("PreProcessing.jl")
    include("PostProcessing.jl")
end